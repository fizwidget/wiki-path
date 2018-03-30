module Pathfinding.Update exposing (update, updateWithArticle)

import RemoteData
import Common.Service exposing (requestArticle)
import Common.Model exposing (Title(Title), Article, value)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Pathfinding.Util exposing (getNextStop)
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
                    updateWithArticle article model

                RemoteData.Failure error ->
                    ( Model.Pathfinding model, Cmd.none )

        Back ->
            Welcome.Init.init


updateWithArticle : Article -> PathfindingModel -> ( Model, Cmd Msg )
updateWithArticle currentArticle model =
    case getNextStop currentArticle model of
        Just nextArticleTitle ->
            if nextArticleTitle == model.end.title then
                Finished.Init.init model.start.title model.end.title model.stops
            else
                ( Model.Pathfinding { model | stops = currentArticle.title :: model.stops }
                , requestArticle ArticleReceived (value nextArticleTitle) |> Cmd.map Messages.Pathfinding
                )

        Nothing ->
            ( Model.Pathfinding { model | error = Just PathNotFound }
            , Cmd.none
            )
