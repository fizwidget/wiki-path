module Pathfinding.Update exposing (update, onArticleReceived)

import RemoteData
import Common.Service exposing (requestArticle)
import Common.Model exposing (Title(Title), Article, value)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Pathfinding.Util exposing (getNextCandidate)
import Pathfinding.Messages exposing (PathfindingMsg(..))
import Pathfinding.Model exposing (PathfindingModel, Error(..))
import Finished.Init
import Welcome.Init


update : PathfindingMsg -> PathfindingModel -> ( Model, Cmd Msg )
update message model =
    case message of
        ArticleReceived remoteArticle ->
            case remoteArticle of
                RemoteData.NotAsked ->
                    ( Model.Pathfinding model, Cmd.none )

                RemoteData.Loading ->
                    ( Model.Pathfinding model, Cmd.none )

                RemoteData.Success article ->
                    onArticleReceived article model

                RemoteData.Failure error ->
                    ( Model.Pathfinding model, Cmd.none )

        Back ->
            Welcome.Init.init


onArticleReceived : Article -> PathfindingModel -> ( Model, Cmd Msg )
onArticleReceived article model =
    case getNextCandidate article model of
        Just candidate ->
            if candidate == model.end.title then
                Finished.Init.init model.start.title model.end.title model.stops
            else
                ( Model.Pathfinding { model | stops = article.title :: model.stops }
                , requestArticle ArticleReceived (value candidate) |> Cmd.map Messages.Pathfinding
                )

        Nothing ->
            ( Model.Pathfinding { model | error = Just PathNotFound }
            , Cmd.none
            )
