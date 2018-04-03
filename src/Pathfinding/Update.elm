module Pathfinding.Update exposing (update, onArticleSuccess)

import RemoteData
import Common.Service exposing (requestArticle)
import Common.Model.Article exposing (Article, ArticleError)
import Common.Model.Title exposing (Title, value)
import Model exposing (Model)
import Messages exposing (Msg(..))
import Pathfinding.Util exposing (suggestNextArticle)
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
                    doNothing model

                RemoteData.Loading ->
                    doNothing model

                RemoteData.Success article ->
                    onArticleSuccess model article

                RemoteData.Failure error ->
                    onArticleError model error

        Back ->
            Welcome.Init.init


doNothing : PathfindingModel -> ( Model, Cmd Msg )
doNothing model =
    ( Model.Pathfinding model, Cmd.none )


onArticleSuccess : PathfindingModel -> Article -> ( Model, Cmd Msg )
onArticleSuccess model currentArticle =
    case suggestNextArticle model currentArticle of
        Just nextArticle ->
            onNextArticleFound model nextArticle

        Nothing ->
            onNextArticleError model currentArticle


onArticleError : PathfindingModel -> ArticleError -> ( Model, Cmd Msg )
onArticleError model error =
    let
        nextModel =
            { model | error = Just <| ArticleError error }
    in
        ( Model.Pathfinding nextModel, Cmd.none )


onNextArticleFound : PathfindingModel -> Title -> ( Model, Cmd Msg )
onNextArticleFound model nextArticle =
    let
        updatedModel =
            { model | stops = nextArticle :: model.stops }
    in
        if hasReachedDestination updatedModel then
            onDestinationReached updatedModel
        else
            ( Model.Pathfinding updatedModel, getArticle nextArticle )


onDestinationReached : PathfindingModel -> ( Model, Cmd Msg )
onDestinationReached { start, end, stops } =
    Finished.Init.init start.title end.title (List.reverse stops)


getArticle : Title -> Cmd Msg
getArticle title =
    requestArticle ArticleReceived (value title)
        |> Cmd.map Messages.Pathfinding


hasReachedDestination : PathfindingModel -> Bool
hasReachedDestination { stops, end } =
    List.head stops
        |> Maybe.map ((==) end.title)
        |> Maybe.withDefault False


onNextArticleError : PathfindingModel -> Article -> ( Model, Cmd Msg )
onNextArticleError model currentArticle =
    ( Model.Pathfinding { model | error = Just (PathNotFound currentArticle.title) }
    , Cmd.none
    )
