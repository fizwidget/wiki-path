module Page.Pathfinding exposing
    ( Model
    , Msg
    , UpdateResult(..)
    , init
    , update
    , view
    )

import Article exposing (Article, ArticleError(..), ArticleResult, Full, Preview)
import Css exposing (..)
import Html.Styled exposing (Html, div, fromUnstyled, h3, li, ol, text, toUnstyled)
import Html.Styled.Attributes exposing (css)
import Http
import OrderedSet exposing (OrderedSet)
import Path exposing (Path)
import PriorityQueue exposing (Priority, PriorityQueue)
import Regex
import Result exposing (Result(..))
import View.Button as Button
import View.Fade as Fade
import View.Spinner as Spinner



-- MODEL


type alias Model =
    { source : Article Full
    , destination : Article Full
    , paths : PriorityQueue Path
    , visitedArticles : OrderedSet String
    , errors : List ArticleError
    , pendingRequests : Int
    , totalRequests : Int
    }



-- CONFIG


totalRequestsLimit : Int
totalRequestsLimit =
    400


pendingRequestsLimit : Int
pendingRequestsLimit =
    4



-- INIT


init : Article Full -> Article Full -> UpdateResult
init source destination =
    articleReceived
        (Path.beginningAt source)
        source
        (initialModel source destination)


initialModel : Article Full -> Article Full -> Model
initialModel source destination =
    { source = source
    , destination = destination
    , paths = PriorityQueue.empty Path.priority
    , visitedArticles = OrderedSet.singleton (Article.getTitle source)
    , errors = []
    , pendingRequests = 0
    , totalRequests = 0
    }



-- UPDATE


type Msg
    = ArticleLoaded Path ArticleResult
    | CancelPathfinding


type UpdateResult
    = InProgress ( Model, Cmd Msg )
    | Cancelled (Article Full) (Article Full)
    | Complete Path
    | PathNotFound (Article Full) (Article Full)
    | TooManyRequests (Article Full) (Article Full)


update : Msg -> Model -> UpdateResult
update msg model =
    case msg of
        ArticleLoaded pathToArticle articleResult ->
            model
                |> decrementPendingRequests
                |> responseReceived pathToArticle articleResult

        CancelPathfinding ->
            Cancelled model.source model.destination


responseReceived : Path -> ArticleResult -> Model -> UpdateResult
responseReceived pathToArticle articleResult model =
    case articleResult of
        Ok article ->
            articleReceived pathToArticle article model

        Err error ->
            errorReceived error model


articleReceived : Path -> Article Full -> Model -> UpdateResult
articleReceived pathToArticle article model =
    if Article.equals article model.destination then
        Complete pathToArticle

    else
        model
            |> processLinks pathToArticle article
            |> continueSearch


errorReceived : ArticleError -> Model -> UpdateResult
errorReceived error model =
    { model | errors = error :: model.errors }
        |> continueSearch


processLinks : Path -> Article Full -> Model -> Model
processLinks pathToArticle article model =
    let
        newPaths =
            article
                |> Article.getLinks
                |> List.filter (isCandidate model.visitedArticles)
                |> List.map (extendPath model.destination pathToArticle)
                |> discardLowPriorities
    in
    { model
        | paths = PriorityQueue.insert model.paths newPaths
        , visitedArticles = markVisited model.visitedArticles newPaths
    }


continueSearch : Model -> UpdateResult
continueSearch model =
    let
        maxPathsToRemove =
            pendingRequestsLimit - model.pendingRequests

        ( pathsToExplore, updatedPriorityQueue ) =
            PriorityQueue.removeHighestPriorities model.paths maxPathsToRemove

        updatedModel =
            { model | paths = updatedPriorityQueue }

        isDeadEnd =
            List.isEmpty pathsToExplore && model.pendingRequests == 0
    in
    if isDeadEnd then
        PathNotFound updatedModel.source updatedModel.destination

    else
        explorePaths updatedModel pathsToExplore


explorePaths : Model -> List Path -> UpdateResult
explorePaths model pathsToFollow =
    case containsPathToDestination pathsToFollow model.destination of
        Just pathToDestination ->
            Complete pathToDestination

        Nothing ->
            fetchNextArticles model pathsToFollow


fetchNextArticles : Model -> List Path -> UpdateResult
fetchNextArticles model pathsToFollow =
    let
        requests =
            List.map fetchNextArticle pathsToFollow

        updatedModel =
            incrementRequests model (List.length requests)
    in
    if updatedModel.totalRequests > totalRequestsLimit then
        TooManyRequests updatedModel.source updatedModel.destination

    else
        InProgress ( updatedModel, Cmd.batch requests )


fetchNextArticle : Path -> Cmd Msg
fetchNextArticle pathToFollow =
    fetchFull (ArticleLoaded pathToFollow) (Path.end pathToFollow)


containsPathToDestination : List Path -> Article Full -> Maybe Path
containsPathToDestination paths destination =
    let
        hasReachedDestination path =
            Article.equals (Path.end path) destination
    in
    paths
        |> List.filter hasReachedDestination
        |> List.sortBy Path.length
        |> List.head


decrementPendingRequests : Model -> Model
decrementPendingRequests model =
    { model | pendingRequests = model.pendingRequests - 1 }


incrementRequests : Model -> Int -> Model
incrementRequests model requestCount =
    { model
        | pendingRequests = model.pendingRequests + requestCount
        , totalRequests = model.totalRequests + requestCount
    }



-- PATHFINDING UTILS


isCandidate : OrderedSet String -> Article Preview -> Bool
isCandidate visitedArticles article =
    let
        title =
            Article.getTitle article

        hasMinimumLength =
            String.length title > 1

        isVisited =
            OrderedSet.member title visitedArticles

        isBlacklisted =
            List.member title
                [ "ISBN"
                , "International Standard Book Number"
                , "International Standard Serial Number"
                , "Digital object identifier"
                , "PubMed"
                , "JSTOR"
                , "Bibcode"
                , "Wayback Machine"
                , "Virtual International Authority File"
                , "Integrated Authority File"
                , "Geographic coordinate system"
                ]
    in
    hasMinimumLength
        && not isVisited
        && not isBlacklisted


markVisited : OrderedSet String -> List Path -> OrderedSet String
markVisited visitedArticles paths =
    paths
        |> List.map (Path.end >> Article.getTitle)
        |> List.foldl OrderedSet.insert visitedArticles


extendPath : Article Full -> Path -> Article Preview -> Path
extendPath destination currentPath nextArticle =
    let
        priority =
            calculatePriority currentPath nextArticle destination
    in
    Path.extend currentPath nextArticle priority


calculatePriority : Path -> Article Preview -> Article Full -> Priority
calculatePriority currentPath current destination =
    if Article.equals current destination then
        10000

    else
        Path.priority currentPath * 0.8 + (heuristic destination current |> toFloat)


heuristic : Article Full -> Article Preview -> Int
heuristic destination current =
    countOccurences
        (Article.getTitle current)
        (Article.getContent destination)


countOccurences : String -> String -> Int
countOccurences target content =
    let
        targetRegex =
            target
                |> escapeForRegex
                |> Regex.fromStringWith { caseInsensitive = True, multiline = False }
                |> Maybe.withDefault Regex.never
    in
    Regex.find targetRegex content
        |> List.length


escapeForRegex : String -> String
escapeForRegex value =
    let
        specialCharacters =
            "[.*+?^${}()|[\\]\\\\]"
                |> Regex.fromString
                |> Maybe.withDefault Regex.never

        escape match =
            "\\" ++ match
    in
    Regex.replace specialCharacters (.match >> escape) value


discardLowPriorities : List Path -> List Path
discardLowPriorities paths =
    paths
        |> List.sortBy (Path.priority >> negate)
        |> List.take 2



-- FETCH


fetchFull : (ArticleResult -> msg) -> Article Preview -> Cmd msg
fetchFull toMsg articlePreview =
    articlePreview
        |> Article.getTitle
        |> Article.fetchNamed
        |> Http.send (toArticleResult >> toMsg)


toArticleResult : Result Http.Error ArticleResult -> ArticleResult
toArticleResult result =
    result
        |> Result.mapError HttpError
        |> Result.andThen identity



-- VIEW


view : Model -> Html Msg
view { source, destination, visitedArticles, paths, errors, totalRequests } =
    div [ css [ displayFlex, flexDirection column, alignItems center ] ]
        [ viewHeading source destination
        , viewWarnings totalRequests destination
        , viewBackButton
        , viewVisited visitedArticles
        ]


viewHeading : Article Full -> Article Full -> Html msg
viewHeading source destination =
    h3 [ css [ textAlign center ] ]
        [ text "Finding path from "
        , Article.viewAsLink source
        , text " to "
        , Article.viewAsLink destination
        , text "..."
        ]


viewVisited : OrderedSet String -> Html msg
viewVisited visited =
    Fade.view <|
        div [ css [ textAlign center, height (px 300), overflow hidden ] ]
            (OrderedSet.inOrder visited
                |> List.take 10
                |> List.map text
                |> List.append [ Spinner.view ]
                |> List.map (List.singleton >> div [])
            )


viewWarnings : Int -> Article Full -> Html msg
viewWarnings totalRequests destination =
    div [ css [ textAlign center ] ]
        [ text <|
            if Article.isDisambiguation destination then
                "The destination is a disambiguation page, so I might not be able to find it! 😅"

            else if Article.getLength destination < 3000 then
                "The destination article is very short, so it might take a while to find! 😅"

            else if totalRequests > totalRequestsLimit // 2 then
                "This isn't looking good. Try a different destination maybe? 💩"

            else
                ""
        ]


viewBackButton : Html Msg
viewBackButton =
    div [ css [ paddingTop (px 8) ] ]
        [ Button.view "Back"
            [ Button.Primary
            , Button.OnClick CancelPathfinding
            ]
        ]
