module Page.Pathfinding
    exposing
        ( Model
        , Msg
        , UpdateResult(..)
        , init
        , update
        , view
        )

import Http
import Html.Styled exposing (Html, fromUnstyled, toUnstyled, text, ol, li, h3, div)
import Html.Styled.Attributes exposing (css)
import Css exposing (..)
import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Result exposing (Result(Ok, Err))
import Article exposing (Article, Preview, Full, ArticleResult, ArticleError(HttpError))
import Path exposing (Path)
import PriorityQueue exposing (PriorityQueue, Priority)
import OrderedSet exposing (OrderedSet)
import Button
import Spinner
import FadeOut


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
    , paths = PriorityQueue.empty
    , visitedArticles = OrderedSet.singleton (Article.title source)
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
            Article.links article
                |> List.filter (isCandidate model.visitedArticles)
                |> List.map (extendPath model.destination pathToArticle)
                |> discardLowPriorities
    in
        { model
            | paths = PriorityQueue.insert model.paths Path.priority newPaths
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
            getNextArticles model pathsToFollow


getNextArticles : Model -> List Path -> UpdateResult
getNextArticles model pathsToFollow =
    let
        requests =
            List.map getNextArticle pathsToFollow

        updatedModel =
            incrementRequests model (List.length requests)
    in
        if updatedModel.totalRequests > totalRequestsLimit then
            TooManyRequests updatedModel.source updatedModel.destination
        else
            InProgress ( updatedModel, Cmd.batch requests )


getNextArticle : Path -> Cmd Msg
getNextArticle pathToFollow =
    let
        articleTitle =
            pathToFollow
                |> Path.end
                |> Article.title
    in
        fetch (ArticleLoaded pathToFollow) articleTitle


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
            Article.title article

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
        |> List.map (Path.end >> Article.title)
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
        (Path.priority currentPath) * 0.8 + (heuristic destination current |> toFloat)


heuristic : Article Full -> Article Preview -> Int
heuristic destination current =
    countOccurences
        (Article.title current)
        (Article.content destination)


countOccurences : String -> String -> Int
countOccurences target content =
    let
        occurencePattern =
            escape target
                |> regex
                |> caseInsensitive
    in
        find All occurencePattern content
            |> List.length


discardLowPriorities : List Path -> List Path
discardLowPriorities paths =
    paths
        |> List.sortBy (Path.priority >> negate)
        |> List.take 2



-- FETCH


fetch : (ArticleResult -> msg) -> String -> Cmd msg
fetch toMsg title =
    title
        |> Article.fetch
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
        , viewVisited visitedArticles
        , viewBackButton
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
    FadeOut.view <|
        div [ css [ textAlign center, height (px 300), overflow hidden ] ]
            (OrderedSet.inOrder visited
                |> List.take 10
                |> List.map text
                |> List.append [ Spinner.view { isVisible = True } ]
                |> List.map (List.singleton >> (div []))
            )


viewWarnings : Int -> Article Full -> Html msg
viewWarnings totalRequests destination =
    div [ css [ textAlign center ] ]
        [ text <|
            if Article.isDisambiguation destination then
                "The destination is a disambiguation page, so I might not be able to find it! 😅"
            else if Article.length destination < 3000 then
                "The destination article is very short, so it might take longer than usual to find! 😅"
            else if totalRequests > totalRequestsLimit // 2 then
                "This isn't looking good. Try a different destination maybe? 💩"
            else
                ""
        ]


viewBackButton : Html Msg
viewBackButton =
    div [ css [ marginTop (px 20) ] ]
        [ Button.view "Back"
            [ Button.Secondary
            , Button.OnClick CancelPathfinding
            ]
        ]
