module PathfindingPage.Update exposing (update)

import RemoteData
import Common.Service exposing (requestArticle)
import Common.Model exposing (Title(Title), Article, stringValue)
import PathfindingPage.Util exposing (getNextCandidate)
import PathfindingPage.Messages exposing (Msg(..))
import PathfindingPage.Model exposing (Model, Error(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update (ArticleReceived remoteArticle) model =
    case remoteArticle of
        RemoteData.NotAsked ->
            ( model, Cmd.none )

        RemoteData.Loading ->
            ( model, Cmd.none )

        RemoteData.Success article ->
            if article.title == model.end.title then
                ( model, Cmd.none )
            else
                onArticleReceived article model

        RemoteData.Failure error ->
            ( model, Cmd.none )


onArticleReceived : Article -> Model -> ( Model, Cmd Msg )
onArticleReceived article model =
    let
        nextModel =
            { model | stops = article.title :: model.stops }

        nextCandidate =
            getNextCandidate article model

        nextCmd =
            nextCandidate
                |> Maybe.map stringValue
                |> Maybe.map (requestArticle ArticleReceived)
                |> Maybe.withDefault Cmd.none
    in
        nextCandidate
            |> Maybe.map (always ( nextModel, nextCmd ))
            |> Maybe.withDefault ( { nextModel | error = Just PathNotFound }, Cmd.none )
