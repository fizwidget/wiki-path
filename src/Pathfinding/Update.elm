module Pathfinding.Update exposing (update, updateWithArticle)

import Result exposing (Result(Ok, Err))
import Common.Article.Service as ArticleService
import Common.Article.Model exposing (Article, ArticleResult, ArticleError)
import Common.Title.Model as Title exposing (Title)
import Common.PriorityQueue.Model as PriorityQueue
import Model exposing (Model)
import Messages exposing (Msg)
import Finished.Init
import Setup.Init
import Pathfinding.Messages exposing (PathfindingMsg(FetchArticleResponse, BackToSetup))
import Pathfinding.Model exposing (PathfindingModel, Path, Error(PathNotFound))
import Pathfinding.Util as Util


update : PathfindingMsg -> PathfindingModel -> ( Model, Cmd Msg )
update message model =
    case message of
        FetchArticleResponse pathSoFar articleResult ->
            updateWithResult model pathSoFar articleResult

        BackToSetup ->
            Setup.Init.init


updateWithResult : PathfindingModel -> Path -> ArticleResult -> ( Model, Cmd Msg )
updateWithResult model pathSoFar articleResult =
    case articleResult of
        Ok nextArticle ->
            if hasReachedDestination nextArticle.title model.destination then
                destinationReached model pathSoFar
            else
                updateWithArticle model pathSoFar nextArticle

        Err error ->
            updateWithError model error


updateWithArticle : PathfindingModel -> Path -> Article -> ( Model, Cmd Msg )
updateWithArticle model pathSoFar nextArticle =
    let
        updatedPriorityQueue =
            Util.addLinksToQueue
                model.priorityQueue
                model.destination
                pathSoFar
                nextArticle.links

        updatedModel =
            { model | priorityQueue = updatedPriorityQueue }
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
        pathCount =
            clamp 1 2 model.concurrencySlots

        ( highestPriorityPaths, updatedPriorityQueue ) =
            PriorityQueue.removeHighestPriorities model.priorityQueue pathCount

        updatedModel =
            { model
                | priorityQueue = updatedPriorityQueue
                , concurrencySlots = max 0 (model.concurrencySlots - pathCount)
            }
    in
        followPaths updatedModel highestPriorityPaths


followPaths : PathfindingModel -> List Path -> ( Model, Cmd Msg )
followPaths model pathsToFollow =
    let
        successfulPath =
            pathsToFollow
                |> List.filter (\pathToFollow -> hasReachedDestination pathToFollow.next model.destination)
                |> List.sortBy (\pathToFollow -> List.length pathToFollow.visited)
                |> List.head
    in
        case successfulPath of
            Just pathToDestination ->
                destinationReached model pathToDestination

            Nothing ->
                ( Model.Pathfinding model, List.map fetchNextArticle pathsToFollow |> Cmd.batch )


destinationReached : PathfindingModel -> Path -> ( Model, Cmd Msg )
destinationReached { source, destination } destinationToSource =
    let
        sourceToDestination =
            (destinationToSource.next :: destinationToSource.visited) |> List.reverse
    in
        Finished.Init.init source.title destination.title sourceToDestination


fetchNextArticle : Path -> Cmd Msg
fetchNextArticle pathSoFar =
    let
        toMsg =
            FetchArticleResponse pathSoFar >> Messages.Pathfinding

        title =
            Title.value pathSoFar.next
    in
        ArticleService.request toMsg title


hasReachedDestination : Title -> Article -> Bool
hasReachedDestination nextTitle destination =
    nextTitle == destination.title


pathNotFound : PathfindingModel -> ( Model, Cmd Msg )
pathNotFound model =
    ( Model.Pathfinding { model | fatalError = Just PathNotFound }
    , Cmd.none
    )
