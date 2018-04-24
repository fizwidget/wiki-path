module Pathfinding.Update exposing (update, updateWithArticle)

import Result exposing (Result(Ok, Err))
import Common.Service exposing (requestArticleResult)
import Common.Model.Article exposing (Article, ArticleError)
import Common.Model.Title exposing (Title, value, from)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Pathfinding.SearchAlgorithm exposing (addNodes)
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
        updatedPriorityQueue =
            addNodes model.priorityQueue model.destination pathTaken article

        updatedModel =
            { model | priorityQueue = updatedPriorityQueue }
    in
        expandHighestPriorityPath updatedModel


updateWithError : PathfindingModel -> ArticleError -> ( Model, Cmd Msg )
updateWithError model error =
    let
        updatedModel =
            { model | errors = error :: model.errors }
    in
        expandHighestPriorityPath updatedModel


expandHighestPriorityPath : PathfindingModel -> ( Model, Cmd Msg )
expandHighestPriorityPath model =
    let
        ( highestPriorityPath, updatedPriorityQueue ) =
            PriorityQueue.removeHighestPriority model.priorityQueue

        updatedModel =
            { model | priorityQueue = updatedPriorityQueue }

        withHighestPriorityPath ({ next, visited } as pathTaken) =
            if hasReachedDestination next updatedModel.destination.title then
                onDestinationReached updatedModel (next :: visited)
            else
                ( Model.Pathfinding updatedModel, getArticle pathTaken )
    in
        highestPriorityPath
            |> Maybe.map withHighestPriorityPath
            |> Maybe.withDefault (onPathNotFound updatedModel)


onDestinationReached : PathfindingModel -> List Title -> ( Model, Cmd Msg )
onDestinationReached { source, destination } pathTaken =
    Finished.Init.init source.title destination.title (List.reverse pathTaken)


getArticle : Path -> Cmd Msg
getArticle pathTaken =
    let
        toMsg =
            FetchArticleResponse pathTaken >> Messages.Pathfinding

        title =
            value pathTaken.next
    in
        requestArticleResult toMsg title


hasReachedDestination : Title -> Title -> Bool
hasReachedDestination current destination =
    current == destination


onPathNotFound : PathfindingModel -> ( Model, Cmd Msg )
onPathNotFound model =
    ( Model.Pathfinding { model | fatalError = Just PathNotFound }
    , Cmd.none
    )
