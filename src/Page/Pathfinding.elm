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
import Bootstrap.Button as ButtonOptions
import Request.Article as Article exposing (ArticleResult, ArticleError)
import Data.Article as Article exposing (Article, Link, Namespace(ArticleNamespace, NonArticleNamespace))
import Data.Path as Path exposing (Path)
import Data.PriorityQueue as PriorityQueue exposing (PriorityQueue, Priority)
import Data.OrderedSet as OrderedSet exposing (OrderedSet)
import Data.Title as Title exposing (Title)
import View.Button as Button
import View.Error as Error
import View.Spinner as Spinner
import View.Link as Link
import View.Fade as Fade


-- MODEL


type alias Model =
    { source : Article
    , destination : Article
    , paths : PriorityQueue Path
    , visitedTitles : VisitedTitles
    , errors : List ArticleError
    , pendingRequests : RequestCount
    , totalRequests : RequestCount
    }


type alias VisitedTitles =
    OrderedSet String


type alias RequestCount =
    Int



-- Config


totalRequestsLimit : RequestCount
totalRequestsLimit =
    400


pendingRequestsLimit : RequestCount
pendingRequestsLimit =
    4



-- INIT


init : Article -> Article -> UpdateResult
init source destination =
    articleReceived
        (Path.beginningWith source.title)
        source
        (initialModel source destination)


initialModel : Article -> Article -> Model
initialModel source destination =
    { source = source
    , destination = destination
    , paths = PriorityQueue.empty
    , visitedTitles = OrderedSet.singleton (Title.value source.title)
    , errors = []
    , pendingRequests = 0
    , totalRequests = 0
    }



-- UPDATE


type Msg
    = ArticleResponse Path ArticleResult
    | AbortRequest


type UpdateResult
    = Continue ( Model, Cmd Msg )
    | PathFound Path
    | PathNotFound Article Article
    | TooManyRequests Article Article
    | Abort Article Article


update : Msg -> Model -> UpdateResult
update msg model =
    case msg of
        ArticleResponse pathToArticle articleResult ->
            model
                |> decrementPendingRequests
                |> responseReceived pathToArticle articleResult

        AbortRequest ->
            Abort model.source model.destination


responseReceived : Path -> ArticleResult -> Model -> UpdateResult
responseReceived pathToArticle articleResult model =
    case articleResult of
        Ok article ->
            articleReceived pathToArticle article model

        Err error ->
            errorReceived error model


articleReceived : Path -> Article -> Model -> UpdateResult
articleReceived pathToArticle article model =
    if hasReachedDestination article model then
        PathFound pathToArticle
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
                |> List.map (extendPath pathToArticle model.destination)
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
            PathFound pathToDestination

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
            Continue ( updatedModel, Cmd.batch requests )


fetchNextArticle : Path -> Cmd Msg
fetchNextArticle pathToFollow =
    let
        articleTitle =
            pathToFollow
                |> Path.nextStop
                |> Title.value
    in
        Article.fetchArticleResult (ArticleResponse pathToFollow) articleTitle


containsPathToDestination : List Path -> Article -> Maybe Path
containsPathToDestination paths destination =
    let
        hasPathReachedDestination destination currentPath =
            Path.nextStop currentPath == destination.title
    in
        paths
            |> List.filter (hasPathReachedDestination destination)
            |> List.sortBy Path.length
            |> List.head


hasReachedDestination : Article -> Model -> Bool
hasReachedDestination article { destination } =
    article.title == destination.title


decrementPendingRequests : Model -> Model
decrementPendingRequests model =
    { model | pendingRequests = model.pendingRequests - 1 }


incrementRequests : Model -> RequestCount -> Model
incrementRequests model requestCount =
    { model
        | pendingRequests = model.pendingRequests + requestCount
        , totalRequests = model.totalRequests + requestCount
    }



-- UTIL


isCandidate : OrderedSet String -> Link -> Bool
isCandidate visitedTitles link =
    let
        title =
            Title.value link.title

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
        link.doesExist
            && hasMinimumLength
            && isRegularArticle
            && not isVisited
            && not isBlacklisted


markVisited : OrderedSet String -> List Path -> OrderedSet String
markVisited visitedTitles newPaths =
    newPaths
        |> List.map (Path.nextStop >> Title.value)
        |> List.foldl OrderedSet.insert visitedTitles


extendPath : Path -> Article -> Link -> Path
extendPath currentPath destination link =
    Path.extend
        currentPath
        link.title
        (calculatePriority destination currentPath link.title)


calculatePriority : Article -> Path -> Title -> Priority
calculatePriority destination currentPath title =
    (Path.priority currentPath) * 0.8 + (heuristic destination title)


heuristic : Article -> Title -> Float
heuristic destination title =
    if title == destination.title then
        10000
    else
        toFloat <| countOccurences destination.content (Title.value title)


countOccurences : String -> String -> Int
countOccurences content target =
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
        , Link.view source.title
        , text " to "
        , Link.view destination.title
        , text "..."
        ]


viewErrors : List ArticleError -> Html msg
viewErrors errors =
    div [] (List.map Error.viewArticleError errors)


viewBackButton : Html Msg
viewBackButton =
    div [ css [ marginTop (px 10) ] ]
        [ Button.view
            [ ButtonOptions.secondary, ButtonOptions.onClick AbortRequest ]
            [ text "Back" ]
        ]


viewWarnings : Int -> Article -> Html msg
viewWarnings totalRequests destination =
    div [ css [ textAlign center ] ]
        [ viewDestinationContentWarning destination
        , viewPathCountWarning totalRequests
        ]


viewDestinationContentWarning : Article -> Html msg
viewDestinationContentWarning destination =
    let
        message =
            if String.contains "disambigbox" destination.content then
                "The destination article is a disambiguation page, so I probably won't be able to find a path to it \x1F916"
            else if String.length destination.content < 10000 then
                "The destination article is very short, so my pathfinding heuristic won't work well \x1F916"
            else
                ""
    in
        div [] [ text message ]


viewPathCountWarning : Int -> Html msg
viewPathCountWarning totalRequests =
    if totalRequests > totalRequestsLimit // 2 then
        div [] [ text "This isn't looking good. Try a different destination maybe? 😅" ]
    else
        text ""


viewVisited : OrderedSet String -> Html msg
viewVisited visited =
    Fade.view
        (div [ css [ textAlign center, height (px 300), overflow hidden ] ]
            (OrderedSet.toList visited
                |> List.take 10
                |> List.map text
                |> List.append [ Spinner.view { isVisible = True } ]
                |> List.map (List.singleton >> (div []))
            )
        )
