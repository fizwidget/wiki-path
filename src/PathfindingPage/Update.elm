module PathfindingPage.Update exposing (update)

import RemoteData
import Common.Service exposing (requestArticle)
import Common.Model exposing (Title(Title), Article, stringValue)
import Model exposing (Model)
import Messages exposing (Msg(..))
import PathfindingPage.Util exposing (getNextCandidate)
import PathfindingPage.Messages exposing (PathfindingMsg(..))
import PathfindingPage.Model exposing (PathfindingModel, Error(..))


update : PathfindingMsg -> PathfindingModel -> ( Model, Cmd Msg )
update (ArticleReceived remoteArticle) model =
    case remoteArticle of
        RemoteData.NotAsked ->
            ( Model.PathfindingPage model, Cmd.none )

        RemoteData.Loading ->
            ( Model.PathfindingPage model, Cmd.none )

        RemoteData.Success article ->
            onArticleReceived article model

        RemoteData.Failure error ->
            ( Model.PathfindingPage model, Cmd.none )


onArticleReceived : Article -> PathfindingModel -> ( Model, Cmd Msg )
onArticleReceived article model =
    case getNextCandidate article model of
        Just candidate ->
            if candidate == model.end.title then
                ( Model.FinishedPage { start = model.start.title, end = model.end.title, stops = model.stops }
                , Cmd.none
                )
            else
                ( Model.PathfindingPage { model | stops = article.title :: model.stops }
                , requestArticle ArticleReceived (stringValue candidate)
                    |> Cmd.map Messages.PathfindingPage
                )

        Nothing ->
            ( Model.PathfindingPage { model | error = Just PathNotFound }
            , Cmd.none
            )
