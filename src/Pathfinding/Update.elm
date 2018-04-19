module Pathfinding.Update exposing (update, onArticleLoaded)

import PairingHeap
import RemoteData
import Common.Service exposing (requestArticle)
import Common.Model.Article exposing (Article, ArticleError)
import Common.Model.Title exposing (Title, value)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Pathfinding.Util exposing (addNodes)
import Pathfinding.Messages exposing (PathfindingMsg(..))
import Pathfinding.Model exposing (PathfindingModel, Error(..))
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
                    onArticleLoadError model error

        BackToSetup ->
            Setup.Init.init


doNothing : PathfindingModel -> ( Model, Cmd Msg )
doNothing model =
    ( Model.Pathfinding model, Cmd.none )


onArticleLoaded : PathfindingModel -> List Title -> Article -> ( Model, Cmd Msg )
onArticleLoaded model pathTaken article =
    let
        modelWithNewNodes =
            addNodes model pathTaken article

        maybePath =
            PairingHeap.findMin modelWithNewNodes.priorityQueue

        modelWithVisitedNodeRemoved =
            { modelWithNewNodes | priorityQueue = PairingHeap.deleteMin modelWithNewNodes.priorityQueue }
    in
        case maybePath of
            Just ( cost, nextTitle :: restOfPath ) ->
                if hasReachedDestination nextTitle model.destination.title then
                    onDestinationReached modelWithNewNodes
                else
                    ( Model.Pathfinding modelWithVisitedNodeRemoved, getArticle nextTitle (nextTitle :: restOfPath) )

            Nothing ->
                ( Model.Pathfinding { modelWithNewNodes | error = Just <| PathNotFound article.title }, Cmd.none )


onArticleLoadError : PathfindingModel -> ArticleError -> ( Model, Cmd Msg )
onArticleLoadError model error =
    ( Model.Pathfinding { model | error = Just <| ArticleError error }
    , Cmd.none
    )


onDestinationReached : PathfindingModel -> ( Model, Cmd Msg )
onDestinationReached { source, destination, stops } =
    Finished.Init.init source.title destination.title (List.reverse stops)


getArticle : Title -> List Title -> Cmd Msg
getArticle title pathTaken =
    requestArticle (\article -> ArticleReceived article pathTaken) (value title)
        |> Cmd.map Messages.Pathfinding


hasReachedDestination : Title -> Title -> Bool
hasReachedDestination current destination =
    current == destination


onPathNotFound : PathfindingModel -> Article -> ( Model, Cmd Msg )
onPathNotFound model currentArticle =
    ( Model.Pathfinding { model | error = Just (PathNotFound currentArticle.title) }
    , Cmd.none
    )
