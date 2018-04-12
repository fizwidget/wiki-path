module Pathfinding.Update exposing (update, onArticleLoaded)

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
import Setup.Init


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
                    onArticleLoaded model article

                RemoteData.Failure error ->
                    onArticleLoadError model error

        BackToSetup ->
            Setup.Init.init


doNothing : PathfindingModel -> ( Model, Cmd Msg )
doNothing model =
    ( Model.Pathfinding model, Cmd.none )


onArticleLoaded : PathfindingModel -> Article -> ( Model, Cmd Msg )
onArticleLoaded model article =
    suggestNextArticle model article
        |> Maybe.map (onNextArticleSuggested model)
        |> Maybe.withDefault (onPathNotFound model article)


onArticleLoadError : PathfindingModel -> ArticleError -> ( Model, Cmd Msg )
onArticleLoadError model error =
    ( Model.Pathfinding { model | error = Just <| ArticleError error }
    , Cmd.none
    )


onNextArticleSuggested : PathfindingModel -> Title -> ( Model, Cmd Msg )
onNextArticleSuggested model nextArticle =
    let
        updatedModel =
            { model | stops = nextArticle :: model.stops }
    in
        if hasReachedDestination updatedModel then
            onDestinationReached updatedModel
        else
            ( Model.Pathfinding updatedModel, getArticle nextArticle )


onDestinationReached : PathfindingModel -> ( Model, Cmd Msg )
onDestinationReached { source, destination, stops } =
    Finished.Init.init source.title destination.title (List.reverse stops)


getArticle : Title -> Cmd Msg
getArticle title =
    requestArticle ArticleReceived (value title)
        |> Cmd.map Messages.Pathfinding


hasReachedDestination : PathfindingModel -> Bool
hasReachedDestination { stops, destination } =
    List.head stops
        |> Maybe.map ((==) destination.title)
        |> Maybe.withDefault False


onPathNotFound : PathfindingModel -> Article -> ( Model, Cmd Msg )
onPathNotFound model currentArticle =
    ( Model.Pathfinding { model | error = Just (PathNotFound currentArticle.title) }
    , Cmd.none
    )
