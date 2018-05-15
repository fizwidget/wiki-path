module Pathfinding.Update exposing (update, updateWithArticle)

import Result exposing (Result(Ok, Err))
import Common.Article.Service as Article
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
            updateWithResult
                (decrementInFlightRequests model)
                pathSoFar
                articleResult

        BackToSetup ->
            Setup.Init.init


updateWithResult : PathfindingModel -> Path -> ArticleResult -> ( Model, Cmd Msg )
updateWithResult model pathSoFar articleResult =
    case articleResult of
        Ok article ->
            if hasReachedDestination article.title model.destination then
                destinationReached model pathSoFar
            else
                updateWithArticle model pathSoFar article

        Err error ->
            updateWithError model error


updateWithArticle : PathfindingModel -> Path -> Article -> ( Model, Cmd Msg )
updateWithArticle model pathSoFar article =
    let
        updatedPriorityQueue =
            Util.addLinksToQueue
                model.priorityQueue
                model.destination
                pathSoFar
                article.links

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
        maxPathsToRemove =
            inFlightRequestLimit - model.inFlightRequests

        ( highestPriorityPaths, updatedPriorityQueue ) =
            PriorityQueue.removeHighestPriorities model.priorityQueue maxPathsToRemove

        isSearchExhausted =
            List.isEmpty highestPriorityPaths && model.inFlightRequests == 0

        updatedModel =
            { model | priorityQueue = updatedPriorityQueue }
    in
        if isSearchExhausted then
            pathNotFound updatedModel
        else
            followPaths updatedModel highestPriorityPaths


followPaths : PathfindingModel -> List Path -> ( Model, Cmd Msg )
followPaths model pathsToFollow =
    shortestPathToDestination pathsToFollow model.destination
        |> Maybe.map (destinationReached model)
        |> Maybe.withDefault (fetchNextArticles model pathsToFollow)


shortestPathToDestination : List Path -> Article -> Maybe Path
shortestPathToDestination paths destination =
    paths
        |> List.filter (\path -> hasReachedDestination path.next destination)
        |> List.sortBy (\path -> List.length path.visited)
        |> List.head


destinationReached : PathfindingModel -> Path -> ( Model, Cmd Msg )
destinationReached { source, destination } destinationToSource =
    let
        sourceToDestination =
            (destinationToSource.next :: destinationToSource.visited) |> List.reverse
    in
        Finished.Init.init source.title destination.title sourceToDestination


fetchNextArticles : PathfindingModel -> List Path -> ( Model, Cmd Msg )
fetchNextArticles model pathsToFollow =
    let
        articleRequests =
            List.map fetchNextArticle pathsToFollow

        updatedModel =
            incrementInFightRequests model (List.length articleRequests)
    in
        ( Model.Pathfinding updatedModel, Cmd.batch articleRequests )


fetchNextArticle : Path -> Cmd Msg
fetchNextArticle pathSoFar =
    Article.request
        (FetchArticleResponse pathSoFar >> Messages.Pathfinding)
        (Title.value pathSoFar.next)


hasReachedDestination : Title -> Article -> Bool
hasReachedDestination nextTitle destination =
    nextTitle == destination.title


pathNotFound : PathfindingModel -> ( Model, Cmd Msg )
pathNotFound model =
    ( Model.Pathfinding { model | fatalError = Just PathNotFound }
    , Cmd.none
    )


inFlightRequestLimit : Int
inFlightRequestLimit =
    4


decrementInFlightRequests : PathfindingModel -> PathfindingModel
decrementInFlightRequests model =
    { model | inFlightRequests = model.inFlightRequests - 1 }


incrementInFightRequests : PathfindingModel -> Int -> PathfindingModel
incrementInFightRequests model requestCount =
    { model | inFlightRequests = model.inFlightRequests + requestCount }
