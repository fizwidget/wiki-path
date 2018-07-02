module Page.Pathfinding
    exposing
        ( Model
        , Msg
        , init
        , update
        , onArticleReceived
        )

import Bootstrap.Button as ButtonOptions
import Common.Article.Fetch as Fetch
import Common.Article.Model exposing (Article, RemoteArticle, ArticleResult, ArticleError, Link, Namespace(ArticleNamespace, NonArticleNamespace))
import Common.Article.View as Article
import Common.Button.View as Button
import Common.Path.Model as Path exposing (Path)
import Common.PriorityQueue.Model as PriorityQueue exposing (PriorityQueue, Priority)
import Common.Spinner.View as Spinner
import Common.Title.Model as Title exposing (Title)
import Common.Title.View as Title
import Css exposing (..)
import Html.Styled exposing (Html, fromUnstyled, toUnstyled, text, ol, li, h3, div)
import Html.Styled.Attributes exposing (css)
import Page.Pathfinding.Util as Util
import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Result exposing (Result(Ok, Err))
import Set exposing (Set)


-- MODEL --


type alias Model =
    { source : Article
    , destination : Article
    , paths : PriorityQueue Path
    , visitedTitles : Set String
    , errors : List ArticleError
    , pendingRequests : Int
    , totalRequests : Int
    }



-- MESSAGES --


type Msg
    = FetchArticleResponse Path ArticleResult
    | BackToSetup



-- INIT --


init : Article -> Article -> UpdateResult
init source destination =
    onArticleReceived
        (initialModel source destination)
        (Path.beginningWith source.title)
        source


initialModel : Article -> Article -> Model
initialModel source destination =
    { source = source
    , destination = destination
    , paths = PriorityQueue.empty
    , visitedTitles = Set.singleton (Title.value source.title)
    , errors = []
    , pendingRequests = 0
    , totalRequests = 0
    }



-- CONFIG --


totalRequestsLimit : Int
totalRequestsLimit =
    400


pendingRequestsLimit : Int
pendingRequestsLimit =
    4



-- UPDATE --


type UpdateResult
    = InPathfinding ( Model, Cmd Msg )
    | Done Path
    | Back
    | PathNotFound
    | TooManyRequests


update : Msg -> Model -> UpdateResult
update message model =
    case message of
        FetchArticleResponse pathToArticle articleResult ->
            onResponseReceived
                (decrementPendingRequests model)
                pathToArticle
                articleResult

        BackToSetup ->
            Back


onResponseReceived : Model -> Path -> ArticleResult -> UpdateResult
onResponseReceived model pathToArticle articleResult =
    case articleResult of
        Ok article ->
            onArticleReceived model pathToArticle article

        Err error ->
            onErrorReceived model error


onArticleReceived : Model -> Path -> Article -> UpdateResult
onArticleReceived model pathToArticle article =
    if hasReachedDestination model article then
        Done pathToArticle
    else
        processLinks model pathToArticle article
            |> continueSearch


onErrorReceived : Model -> ArticleError -> UpdateResult
onErrorReceived model error =
    { model | errors = error :: model.errors }
        |> continueSearch


processLinks : Model -> Path -> Article -> Model
processLinks model pathToArticle article =
    let
        candidateLinks =
            List.filter (Util.isCandidate model.visitedTitles) article.links

        newPaths =
            candidateLinks
                |> List.map (Util.extendPath pathToArticle model.destination)
                |> Util.discardLowPriorityPaths
    in
        { model
            | paths = PriorityQueue.insert model.paths Path.priority newPaths
            , visitedTitles = Util.markVisited model.visitedTitles newPaths
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

        areNoPathsAvailable =
            List.isEmpty pathsToExplore && model.pendingRequests == 0
    in
        if areNoPathsAvailable then
            PathNotFound
        else
            explorePaths updatedModel pathsToExplore


explorePaths : Model -> List Path -> UpdateResult
explorePaths model paths =
    case containsPathToDestination model.destination paths of
        Just pathToDestination ->
            Done pathToDestination

        Nothing ->
            fetchNextArticles model paths


fetchNextArticles : Model -> List Path -> UpdateResult
fetchNextArticles model pathsToFollow =
    let
        requests =
            List.map fetchNextArticle pathsToFollow

        requestCount =
            List.length requests

        updatedModel =
            incrementRequests model requestCount
    in
        if hasMadeTooManyRequests updatedModel then
            TooManyRequests
        else
            InPathfinding ( updatedModel, Cmd.batch requests )


fetchNextArticle : Path -> Cmd Msg
fetchNextArticle pathToFollow =
    let
        toMsg =
            FetchArticleResponse pathToFollow

        title =
            (Path.nextStop >> Title.value) pathToFollow
    in
        Fetch.articleResult toMsg title


containsPathToDestination : Article -> List Path -> Maybe Path
containsPathToDestination destination paths =
    let
        hasPathReachedDestination destination currentPath =
            Path.nextStop currentPath == destination.title
    in
        paths
            |> List.filter (hasPathReachedDestination destination)
            |> List.sortBy Path.length
            |> List.head


hasReachedDestination : Model -> Article -> Bool
hasReachedDestination { destination } nextArticle =
    nextArticle.title == destination.title


hasMadeTooManyRequests : Model -> Bool
hasMadeTooManyRequests { totalRequests } =
    totalRequests > totalRequestsLimit


decrementPendingRequests : Model -> Model
decrementPendingRequests model =
    { model | pendingRequests = model.pendingRequests - 1 }


incrementRequests : Model -> Int -> Model
incrementRequests model requestCount =
    { model
        | pendingRequests = model.pendingRequests + requestCount
        , totalRequests = model.totalRequests + requestCount
    }



-- UTIL --


isCandidate : Set String -> Link -> Bool
isCandidate visitedTitles link =
    let
        title =
            Title.value link.title

        hasMinimumLength =
            String.length title > 1

        isVisited =
            Set.member title visitedTitles

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


markVisited : Set String -> List Path -> Set String
markVisited visitedTitles newPaths =
    newPaths
        |> List.map (Path.nextStop >> Title.value)
        |> List.foldl Set.insert visitedTitles


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


discardLowPriorityPaths : List Path -> List Path
discardLowPriorityPaths paths =
    paths
        |> List.sortBy (Path.priority >> negate)
        |> List.take 2



-- VIEW --


view : Model -> Html Msg
view { source, destination, paths, errors, totalRequests } =
    div [ css [ displayFlex, flexDirection column, alignItems center ] ]
        [ viewHeading source destination
        , viewErrors errors
        , viewWarnings totalRequests destination
        , viewBackButton
        , viewPaths paths
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
    div [] <| List.map Article.viewError errors


viewBackButton : Html Msg
viewBackButton =
    div [ css [ margin (px 20) ] ]
        [ Button.view
            [ ButtonOptions.secondary, ButtonOptions.onClick BackToSetup ]
            [ text "Back" ]
        ]


viewWarnings : Int -> Article -> Html msg
viewWarnings totalRequests destination =
    div [ css [ textAlign center ] ]
        [ destinationContentWarning destination
        , pathCountWarning totalRequests
        ]


destinationContentWarning : Article -> Html msg
destinationContentWarning destination =
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


pathCountWarning : Int -> Html msg
pathCountWarning totalRequests =
    if totalRequests > totalRequestsLimit // 2 then
        div [] [ text "This isn't looking good. Try a different destination maybe? 😅" ]
    else
        text ""


viewPaths : PriorityQueue Path -> Html msg
viewPaths paths =
    PriorityQueue.getHighestPriority paths
        |> Maybe.map pathView
        |> Maybe.withDefault (div [] [])


pathView : Path -> Html msg
pathView path =
    div [ css [ textAlign center ] ]
        [ Path.inReverseOrder path
            |> List.map Title.viewAsLink
            |> List.intersperse (text "↑")
            |> List.append [ text "↑" ]
            |> List.append [ Spinner.view { isVisible = True } ]
            |> List.map (List.singleton >> div [])
            |> div []
        ]