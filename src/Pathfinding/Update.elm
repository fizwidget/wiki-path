module Pathfinding.Update exposing (update, updateWithArticle)

import Set
import Result exposing (Result(Ok, Err))
import Common.Service exposing (requestArticleResult)
import Common.Model.Article exposing (Article, ArticleError)
import Common.Model.Title as Title exposing (Title)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Pathfinding.Util exposing (addArticleLinks)
import Pathfinding.Messages exposing (PathfindingMsg(..))
import Pathfinding.Model exposing (PathfindingModel, Path, Error(..))
import Pathfinding.Model.PriorityQueue as PriorityQueue
import Finished.Init
import Setup.Init


update : PathfindingMsg -> PathfindingModel -> ( Model, Cmd Msg )
update message model =
    case message of
        FetchArticleResponse pathSoFar articleResult ->
            case articleResult of
                Ok article ->
                    updateWithArticle model pathSoFar article

                Err error ->
                    updateWithError model error

        BackToSetup ->
            Setup.Init.init


updateWithArticle : PathfindingModel -> Path -> Article -> ( Model, Cmd Msg )
updateWithArticle model pathSoFar article =
    let
        isUnvisited title =
            not <| Set.member (Title.value title) model.visitedTitles

        updatedPriorityQueue =
            addArticleLinks
                model.priorityQueue
                model.destination
                pathSoFar
                isUnvisited
                article

        updatedModel =
            { model | priorityQueue = updatedPriorityQueue }
    in
        followHighestPriorityPath updatedModel


updateWithError : PathfindingModel -> ArticleError -> ( Model, Cmd Msg )
updateWithError model error =
    let
        updatedModel =
            { model | errors = error :: model.errors }
    in
        followHighestPriorityPath updatedModel


followHighestPriorityPath : PathfindingModel -> ( Model, Cmd Msg )
followHighestPriorityPath model =
    let
        ( highestPriorityPath, updatedPriorityQueue ) =
            PriorityQueue.removeHighestPriority model.priorityQueue

        updatedModel =
            { model | priorityQueue = updatedPriorityQueue }
    in
        highestPriorityPath
            |> Maybe.map (explorePath updatedModel)
            |> Maybe.withDefault (pathNotFound updatedModel)


explorePath : PathfindingModel -> Path -> ( Model, Cmd Msg )
explorePath model newPath =
    if hasReachedDestination newPath model.destination then
        destinationReached model newPath
    else
        ( markVisited newPath.next model |> Model.Pathfinding
        , fetchNextArticle newPath
        )


markVisited : Title -> PathfindingModel -> PathfindingModel
markVisited title model =
    { model | visitedTitles = Set.insert (Title.value title) model.visitedTitles }


destinationReached : PathfindingModel -> Path -> ( Model, Cmd Msg )
destinationReached { source, destination } destinationToSource =
    Finished.Init.init
        source.title
        destination.title
        (List.reverse <| destinationToSource.next :: destinationToSource.visited)


fetchNextArticle : Path -> Cmd Msg
fetchNextArticle pathSoFar =
    let
        toMsg =
            FetchArticleResponse pathSoFar >> Messages.Pathfinding

        title =
            Title.value pathSoFar.next
    in
        requestArticleResult toMsg title


hasReachedDestination : Path -> Article -> Bool
hasReachedDestination pathSoFar destination =
    pathSoFar.next == destination.title


pathNotFound : PathfindingModel -> ( Model, Cmd Msg )
pathNotFound model =
    ( Model.Pathfinding { model | fatalError = Just PathNotFound }
    , Cmd.none
    )
