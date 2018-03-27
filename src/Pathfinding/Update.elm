module Pathfinding.Update exposing (update)

import RemoteData
import Common.Service exposing (requestArticle)
import Common.Model exposing (Title(Title), Article, stringValue)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Pathfinding.Util exposing (getNextCandidate)
import Pathfinding.Messages exposing (PathfindingMsg(..))
import Pathfinding.Model exposing (PathfindingModel, Error(..))


update : PathfindingMsg -> PathfindingModel -> ( Model, Cmd Msg )
update (ArticleReceived remoteArticle) model =
    case remoteArticle of
        RemoteData.NotAsked ->
            ( Model.Pathfinding model, Cmd.none )

        RemoteData.Loading ->
            ( Model.Pathfinding model, Cmd.none )

        RemoteData.Success article ->
            onArticleReceived article model

        RemoteData.Failure error ->
            ( Model.Pathfinding model, Cmd.none )


onArticleReceived : Article -> PathfindingModel -> ( Model, Cmd Msg )
onArticleReceived article model =
    case getNextCandidate article model of
        Just candidate ->
            if candidate == model.end.title then
                ( Model.Finished { start = model.start.title, end = model.end.title, stops = model.stops }
                , Cmd.none
                )
            else
                ( Model.Pathfinding { model | stops = article.title :: model.stops }
                , requestArticle ArticleReceived (stringValue candidate)
                    |> Cmd.map Messages.Pathfinding
                )

        Nothing ->
            ( Model.Pathfinding { model | error = Just PathNotFound }
            , Cmd.none
            )
