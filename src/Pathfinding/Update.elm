module Pathfinding.Update exposing (update, updateWithResponse)

import Result exposing (Result(Ok, Err))
import Common.Article.Model exposing (Article, ArticleResult, ArticleError)
import Common.Title.Model as Title exposing (Title)
import Common.Path.Model as Path exposing (Path)
import Common.PriorityQueue.Model as PriorityQueue exposing (PriorityQueue)
import Model exposing (Model)
import Messages exposing (Msg)
import Finished.Init
import Setup.Init
import Pathfinding.Messages exposing (PathfindingMsg(FetchArticleResponse, BackToSetup))
import Pathfinding.Model exposing (PathfindingModel)
import Pathfinding.Fetch as Fetch
import Pathfinding.Util as Util
import Pathfinding.Constants as Constants


update : PathfindingMsg -> PathfindingModel -> ( Model, Cmd Msg )
update message model =
    case message of
        FetchArticleResponse pathToArticle articleResult ->
            updateWithResponse
                (decrementPendingRequests model)
                pathToArticle
                articleResult

        BackToSetup ->
            Setup.Init.initWithTitles
                model.source.title
                model.destination.title


updateWithResponse : PathfindingModel -> Path -> ArticleResult -> ( Model, Cmd Msg )
updateWithResponse model pathToArticle articleResult =
    case articleResult of
        Ok article ->
            if hasReachedDestination model article then
                pathFound pathToArticle
            else
                updateWithArticle model pathToArticle article

        Err error ->
            updateWithError model error


updateWithArticle : PathfindingModel -> Path -> Article -> ( Model, Cmd Msg )
updateWithArticle model pathToArticle article =
    let
        newPaths =
            article.links
                |> List.filter Util.isInteresting
                |> List.filter (Util.isUnvisited model.visitedTitles)
                |> List.map (Util.extendPath pathToArticle model.destination)
                |> Util.discardLowPriorityPaths

        updatedModel =
            { model
                | paths = PriorityQueue.insert model.paths Path.priority newPaths
                , visitedTitles = Util.markVisited model.visitedTitles newPaths
            }
    in
        followHighestPriorityPaths updatedModel


updateWithError : PathfindingModel -> ArticleError -> ( Model, Cmd Msg )
updateWithError model error =
    let
        updatedModel =
            { model | errors = error :: model.errors }
    in
        followHighestPriorityPaths updatedModel


followHighestPriorityPaths : PathfindingModel -> ( Model, Cmd Msg )
followHighestPriorityPaths model =
    let
        maxPathsToRemove =
            Constants.maxPendingRequests - model.pendingRequests

        ( highestPriorityPaths, updatedPriorityQueue ) =
            PriorityQueue.removeHighestPriorities model.paths maxPathsToRemove

        updatedModel =
            { model | paths = updatedPriorityQueue }

        hasPathfindingFailed =
            List.isEmpty highestPriorityPaths && model.pendingRequests == 0
    in
        if hasPathfindingFailed then
            pathNotFoundError model
        else
            followPaths updatedModel highestPriorityPaths


followPaths : PathfindingModel -> List Path -> ( Model, Cmd Msg )
followPaths model paths =
    case containsPathToDestination model.destination paths of
        Just pathToDestination ->
            pathFound pathToDestination

        Nothing ->
            fetchNextArticles model paths


fetchNextArticles : PathfindingModel -> List Path -> ( Model, Cmd Msg )
fetchNextArticles model pathsToFollow =
    let
        requests =
            List.map fetchNextArticle pathsToFollow

        updatedModel =
            incrementRequests model (List.length requests)
    in
        if hasMadeTooManyRequests updatedModel then
            tooManyRequestsError updatedModel
        else
            ( Model.Pathfinding updatedModel, Cmd.batch requests )


fetchNextArticle : Path -> Cmd Msg
fetchNextArticle pathToFollow =
    let
        toMsg =
            FetchArticleResponse pathToFollow >> Messages.Pathfinding

        title =
            (Path.nextStop >> Title.value) pathToFollow
    in
        Fetch.article toMsg title


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


hasReachedDestination : PathfindingModel -> Article -> Bool
hasReachedDestination { destination } nextArticle =
    nextArticle.title == destination.title


hasMadeTooManyRequests : PathfindingModel -> Bool
hasMadeTooManyRequests { totalRequests } =
    totalRequests > Constants.maxTotalRequests


pathFound : Path -> ( Model, Cmd Msg )
pathFound =
    Finished.Init.initWithPath


tooManyRequestsError : PathfindingModel -> ( Model, Cmd Msg )
tooManyRequestsError { source, destination } =
    Finished.Init.initWithTooManyRequestsError source destination


pathNotFoundError : PathfindingModel -> ( Model, Cmd Msg )
pathNotFoundError { source, destination } =
    Finished.Init.initWithPathNotFoundError source destination


decrementPendingRequests : PathfindingModel -> PathfindingModel
decrementPendingRequests model =
    { model | pendingRequests = model.pendingRequests - 1 }


incrementRequests : PathfindingModel -> Int -> PathfindingModel
incrementRequests model requestCount =
    { model
        | pendingRequests = model.pendingRequests + requestCount
        , totalRequests = model.totalRequests + requestCount
    }
