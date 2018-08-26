module Page.Pathfinding
    exposing
        ( Model
        , Msg
        , UpdateResult(..)
        , init
        , update
        , view
        )

import Html.Styled exposing (Html, fromUnstyled, toUnstyled, text, ol, li, h3, div)
import Html.Styled.Attributes exposing (css)
import Css exposing (..)
import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Result exposing (Result(Ok, Err))
import Article exposing (Article, Link, Namespace(ArticleNamespace, NonArticleNamespace), ArticleResult, ArticleError)
import Path exposing (Path)
import PriorityQueue exposing (PriorityQueue, Priority)
import OrderedSet exposing (OrderedSet)
import Title exposing (Title)
import Button
import Spinner
import FadeOut


-- MODEL


type alias Model =
    { source : Article
    , destination : Article
    , paths : PriorityQueue Path
    , visitedTitles : OrderedSet String
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


init : Article -> Article -> UpdateResult
init source destination =
    articleReceived
        (Path.beginningAt source.title)
        source
        (initialModel source destination)


initialModel : Article -> Article -> Model
initialModel source destination =
    { source = source
    , destination = destination
    , paths = PriorityQueue.empty
    , visitedTitles = OrderedSet.singleton (Title.asString source.title)
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
    | Cancelled Article Article
    | Complete Path
    | PathNotFound Article Article
    | TooManyRequests Article Article


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


articleReceived : Path -> Article -> Model -> UpdateResult
articleReceived pathToArticle article model =
    if article.title == model.destination.title then
        Complete pathToArticle
    else
        model
            |> processLinks pathToArticle article
            |> continueSearch


errorReceived : ArticleError -> Model -> UpdateResult
errorReceived error model =
    { model | errors = error :: model.errors }
        |> continueSearch


processLinks : Path -> Article -> Model -> Model
processLinks pathToArticle article model =
    let
        newPaths =
            article.links
                |> List.filter (isCandidate model.visitedTitles)
                |> List.map (extendPath model.destination pathToArticle)
                |> discardLowPriorities
    in
        { model
            | paths = PriorityQueue.insert model.paths Path.priority newPaths
            , visitedTitles = markVisited model.visitedTitles newPaths
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
                |> Title.asString
    in
        Article.getArticleResult (ArticleLoaded pathToFollow) articleTitle


containsPathToDestination : List Path -> Article -> Maybe Path
containsPathToDestination paths destination =
    let
        hasReachedDestination path =
            Path.end path == destination.title
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


isCandidate : OrderedSet String -> Link -> Bool
isCandidate visitedTitles link =
    let
        title =
            Title.asString link.title

        hasMinimumLength =
            String.length title > 1

        isVisited =
            OrderedSet.member title visitedTitles

        isRegularArticle =
            link.namespace == ArticleNamespace

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
        link.exists
            && hasMinimumLength
            && isRegularArticle
            && not isVisited
            && not isBlacklisted


markVisited : OrderedSet String -> List Path -> OrderedSet String
markVisited visitedTitles paths =
    paths
        |> List.map (Path.end >> Title.asString)
        |> List.foldl OrderedSet.insert visitedTitles


extendPath : Article -> Path -> Link -> Path
extendPath destination currentPath link =
    let
        priority =
            calculatePriority currentPath link.title destination
    in
        Path.extend currentPath link.title priority


calculatePriority : Path -> Title -> Article -> Priority
calculatePriority currentPath title destination =
    (Path.priority currentPath) * 0.8 + (heuristic destination title)


heuristic : Article -> Title -> Float
heuristic destination title =
    if title == destination.title then
        10000
    else
        countOccurences (Title.asString title) destination.content
            |> toFloat


countOccurences : String -> String -> Int
countOccurences target content =
    let
        occurencePattern =
            ("(^|\\s+|\")" ++ (escape target) ++ "(\\s+|$|\")")
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



-- VIEW


view : Model -> Html Msg
view { source, destination, visitedTitles, paths, errors, totalRequests } =
    div [ css [ displayFlex, flexDirection column, alignItems center ] ]
        [ viewHeading source destination
        , viewErrors errors
        , viewWarnings totalRequests destination
        , viewBackButton
        , viewVisited visitedTitles
        ]


viewHeading : Article -> Article -> Html msg
viewHeading source destination =
    h3 [ css [ textAlign center ] ]
        [ text "Finding path from "
        , Title.viewAsLink source.title
        , text " to "
        , Title.viewAsLink destination.title
        , text "..."
        ]


viewErrors : List ArticleError -> Html msg
viewErrors errors =
    errors
        |> List.head
        |> Maybe.map Article.viewError
        |> Maybe.withDefault (text "")


viewBackButton : Html Msg
viewBackButton =
    div [ css [ marginTop (px 10) ] ]
        [ Button.view "Back"
            [ Button.Secondary
            , Button.OnClick CancelPathfinding
            ]
        ]


viewWarnings : Int -> Article -> Html msg
viewWarnings totalRequests destination =
    div [ css [ textAlign center ] ]
        [ viewDestinationContentWarning destination
        , viewPathCountWarning totalRequests
        ]


viewDestinationContentWarning : Article -> Html msg
viewDestinationContentWarning destination =
    div []
        [ text <|
            if String.contains "disambigbox" destination.content then
                "The destination is a disambiguation page, so I probably won't be able to find it! 😅"
            else if String.length destination.content < 10000 then
                "The destination article is very short, so it might take longer than usual to find! 😅"
            else
                ""
        ]


viewPathCountWarning : Int -> Html msg
viewPathCountWarning totalRequests =
    if totalRequests > totalRequestsLimit // 2 then
        div [] [ text "This isn't looking good. Try a different destination maybe? 💩" ]
    else
        text ""


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
