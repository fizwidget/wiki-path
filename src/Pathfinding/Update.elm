module Pathfinding.Update exposing (update, updateWithResult)

import Result exposing (Result(Ok, Err))
import Common.Article.Service as Article
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
import Pathfinding.Util as Util


update : PathfindingMsg -> PathfindingModel -> ( Model, Cmd Msg )
update message model =
    case message of
        FetchArticleResponse currentPath articleResult ->
            updateWithResult
                (decrementPendingRequests model)
                currentPath
                articleResult

        BackToSetup ->
            Setup.Init.init


updateWithResult : PathfindingModel -> Path -> ArticleResult -> ( Model, Cmd Msg )
updateWithResult model currentPath articleResult =
    case articleResult of
        Ok article ->
            if hasReachedDestination article.title model.destination then
                destinationReached currentPath
            else
                updateWithArticle model currentPath article

        Err error ->
            updateWithError model error


updateWithArticle : PathfindingModel -> Path -> Article -> ( Model, Cmd Msg )
updateWithArticle model currentPath article =
    let
        newPaths =
            article.links
                |> List.filter Util.isInteresting
                |> List.filter (Util.isUnvisited model.paths currentPath)
                |> List.map (Util.extendPath currentPath model.destination)
                |> Util.keepHighestPriorities

        updatedModel =
            { model | paths = PriorityQueue.insert model.paths Path.priority newPaths }
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
            maxPendingRequests - model.pendingRequests

        ( highestPriorityPaths, updatedPriorityQueue ) =
            PriorityQueue.removeHighestPriorities model.paths maxPathsToRemove

        updatedModel =
            { model | paths = updatedPriorityQueue }

        hasPathfindingFailed =
            List.isEmpty highestPriorityPaths && model.pendingRequests == 0
    in
        if hasPathfindingFailed then
            Finished.Init.initWithPathNotFound
        else
            followPaths updatedModel highestPriorityPaths


followPaths : PathfindingModel -> List Path -> ( Model, Cmd Msg )
followPaths model paths =
    let
        maybePathToDestination =
            paths
                |> List.filter (hasPathReachedDestination model.destination)
                |> List.sortBy Path.length
                |> List.head
    in
        maybePathToDestination
            |> Maybe.map destinationReached
            |> Maybe.withDefault (fetchNextArticles model paths)


destinationReached : Path -> ( Model, Cmd Msg )
destinationReached =
    Finished.Init.initWithPath


fetchNextArticles : PathfindingModel -> List Path -> ( Model, Cmd Msg )
fetchNextArticles model pathsToFollow =
    let
        articleRequests =
            List.map fetchNextArticle pathsToFollow

        updatedModel =
            incrementRequests model (List.length articleRequests)
    in
        if hasMadeTooManyRequests model then
            Finished.Init.initWithTooManyRequestsError
        else
            ( Model.Pathfinding updatedModel, Cmd.batch articleRequests )


fetchNextArticle : Path -> Cmd Msg
fetchNextArticle currentPath =
    Article.request
        (FetchArticleResponse currentPath >> Messages.Pathfinding)
        (Path.nextStop currentPath |> Title.value)


hasReachedDestination : Title -> Article -> Bool
hasReachedDestination nextTitle destination =
    nextTitle == destination.title


hasPathReachedDestination : Article -> Path -> Bool
hasPathReachedDestination destination currentPath =
    hasReachedDestination (Path.nextStop currentPath) destination


hasMadeTooManyRequests : PathfindingModel -> Bool
hasMadeTooManyRequests { totalRequests } =
    totalRequests > 200


maxPendingRequests : Int
maxPendingRequests =
    4


decrementPendingRequests : PathfindingModel -> PathfindingModel
decrementPendingRequests model =
    { model | pendingRequests = model.pendingRequests - 1 }


incrementRequests : PathfindingModel -> Int -> PathfindingModel
incrementRequests model requestCount =
    { model
        | pendingRequests = model.pendingRequests + requestCount
        , totalRequests = model.totalRequests + requestCount
    }
