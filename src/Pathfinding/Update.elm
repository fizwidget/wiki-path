module Pathfinding.Update exposing (update, onArticleLoaded)

import PairingHeap
import RemoteData
import Common.Service exposing (requestArticle)
import Common.Model.Article exposing (Article, ArticleError)
import Common.Model.Title exposing (Title, value, from)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Pathfinding.Util exposing (addNodes)
import Pathfinding.Messages exposing (PathfindingMsg(..))
import Pathfinding.Model exposing (PathfindingModel, Path, Error(..))
import Finished.Init
import Setup.Init


update : PathfindingMsg -> PathfindingModel -> ( Model, Cmd Msg )
update message model =
    case message of
        ArticleReceived remoteArticle pathTaken ->
            case remoteArticle of
                RemoteData.NotAsked ->
                    doNothing model

                RemoteData.Loading ->
                    doNothing model

                RemoteData.Success article ->
                    onArticleLoaded model pathTaken article

                RemoteData.Failure error ->
                    onArticleLoadError model pathTaken.visited error

        BackToSetup ->
            Setup.Init.init


doNothing : PathfindingModel -> ( Model, Cmd Msg )
doNothing model =
    ( Model.Pathfinding model, Cmd.none )


onArticleLoaded : PathfindingModel -> Path -> Article -> ( Model, Cmd Msg )
onArticleLoaded model pathTaken article =
    let
        ( nextModel, lowestCostPath ) =
            popMin <| addNodes model pathTaken article
    in
        withLowestCostPath nextModel lowestCostPath


withLowestCostPath : PathfindingModel -> Maybe Path -> ( Model, Cmd Msg )
withLowestCostPath nextModel lowestCostPath =
    case lowestCostPath of
        Just ({ cost, next, visited } as path) ->
            if hasReachedDestination next nextModel.destination.title then
                onDestinationReached nextModel (next :: visited)
            else
                ( Model.Pathfinding nextModel
                , getArticle path
                )

        Nothing ->
            onPathNotFound nextModel


popMin : PathfindingModel -> ( PathfindingModel, Maybe Path )
popMin model =
    ( { model | priorityQueue = PairingHeap.deleteMin model.priorityQueue }
    , PairingHeap.findMin model.priorityQueue
        |> Maybe.map (Debug.log "Min")
        |> Maybe.map Tuple.second
    )


onArticleLoadError : PathfindingModel -> List Title -> ArticleError -> ( Model, Cmd Msg )
onArticleLoadError model pathTaken error =
    let
        ( nextModel, lowestCostPath ) =
            popMin model
    in
        withLowestCostPath nextModel lowestCostPath


onDestinationReached : PathfindingModel -> List Title -> ( Model, Cmd Msg )
onDestinationReached { source, destination } pathTaken =
    Finished.Init.init source.title destination.title (List.reverse pathTaken)


getArticle : Path -> Cmd Msg
getArticle pathTaken =
    requestArticle (\article -> ArticleReceived article pathTaken) (value pathTaken.next)
        |> Cmd.map Messages.Pathfinding


hasReachedDestination : Title -> Title -> Bool
hasReachedDestination current destination =
    current == destination


onPathNotFound : PathfindingModel -> ( Model, Cmd Msg )
onPathNotFound model =
    ( Model.Pathfinding { model | error = Just (PathNotFound <| from "Fix this type problem!") }
    , Cmd.none
    )
