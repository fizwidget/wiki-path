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
        FetchArticleResponse pathTaken articleResult ->
            case articleResult of
                Ok article ->
                    updateWithArticle model pathTaken article

                Err error ->
                    updateWithError model error

        BackToSetup ->
            Setup.Init.init


updateWithArticle : PathfindingModel -> Path -> Article -> ( Model, Cmd Msg )
updateWithArticle model pathTaken article =
    let
        isVisited title =
            Set.member (Title.value title) model.visitedTitles

        updatedPriorityQueue =
            addArticleLinks
                model.priorityQueue
                model.destination
                pathTaken
                isVisited
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

        markVisited title model =
            { model | visitedTitles = Set.insert (Title.value title) model.visitedTitles }

        explorePath pathTaken =
            if hasReachedDestination pathTaken updatedModel then
                destinationReached updatedModel pathTaken
            else
                ( Model.Pathfinding <| markVisited pathTaken.next updatedModel
                , followPath pathTaken
                )
    in
        highestPriorityPath
            |> Maybe.map explorePath
            |> Maybe.withDefault (pathNotFound updatedModel)


destinationReached : PathfindingModel -> Path -> ( Model, Cmd Msg )
destinationReached { source, destination } destinationToSource =
    Finished.Init.init
        source.title
        destination.title
        (List.reverse <| destinationToSource.next :: destinationToSource.visited)


followPath : Path -> Cmd Msg
followPath pathTaken =
    let
        toMsg =
            FetchArticleResponse pathTaken >> Messages.Pathfinding

        title =
            Title.value pathTaken.next
    in
        requestArticleResult toMsg title


hasReachedDestination : Path -> PathfindingModel -> Bool
hasReachedDestination pathTaken model =
    pathTaken.next == model.destination.title


pathNotFound : PathfindingModel -> ( Model, Cmd Msg )
pathNotFound model =
    ( Model.Pathfinding { model | fatalError = Just PathNotFound }
    , Cmd.none
    )
