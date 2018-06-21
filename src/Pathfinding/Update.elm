module Pathfinding.Update exposing (update, onArticleReceived)

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
import Pathfinding.Config as Config


update : PathfindingMsg -> PathfindingModel -> ( Model, Cmd Msg )
update message model =
    case message of
        FetchArticleResponse pathToArticle articleResult ->
            onResponseReceived
                (decrementPendingRequests model)
                pathToArticle
                articleResult

        BackToSetup ->
            Setup.Init.initWithTitles
                model.source.title
                model.destination.title


onResponseReceived : PathfindingModel -> Path -> ArticleResult -> ( Model, Cmd Msg )
onResponseReceived model pathToArticle articleResult =
    case articleResult of
        Ok article ->
            onArticleReceived model pathToArticle article

        Err error ->
            onErrorReceived model error


onArticleReceived : PathfindingModel -> Path -> Article -> ( Model, Cmd Msg )
onArticleReceived model pathToArticle article =
    if hasReachedDestination model article then
        destinationReached pathToArticle
    else
        processLinks model pathToArticle article
            |> continueSearch


onErrorReceived : PathfindingModel -> ArticleError -> ( Model, Cmd Msg )
onErrorReceived model error =
    { model | errors = error :: model.errors }
        |> continueSearch


processLinks : PathfindingModel -> Path -> Article -> PathfindingModel
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


continueSearch : PathfindingModel -> ( Model, Cmd Msg )
continueSearch model =
    let
        maxPathsToRemove =
            Config.pendingRequestsLimit - model.pendingRequests

        ( pathsToExplore, updatedPriorityQueue ) =
            PriorityQueue.removeHighestPriorities model.paths maxPathsToRemove

        updatedModel =
            { model | paths = updatedPriorityQueue }

        areNoPathsAvailable =
            List.isEmpty pathsToExplore && model.pendingRequests == 0
    in
        if areNoPathsAvailable then
            pathNotFoundError updatedModel
        else
            explorePaths updatedModel pathsToExplore


explorePaths : PathfindingModel -> List Path -> ( Model, Cmd Msg )
explorePaths model paths =
    case containsPathToDestination model.destination paths of
        Just pathToDestination ->
            destinationReached pathToDestination

        Nothing ->
            fetchNextArticles model paths


fetchNextArticles : PathfindingModel -> List Path -> ( Model, Cmd Msg )
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
    totalRequests > Config.totalRequestsLimit


destinationReached : Path -> ( Model, Cmd Msg )
destinationReached =
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
