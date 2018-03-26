module PathfindingPage.Update exposing (update)

import RemoteData
import Common.Service exposing (requestArticle)
import Common.Model exposing (Title(Title), Article, unbox)
import PathfindingPage.Util exposing (getNextCandidate)
import PathfindingPage.Messages exposing (Msg(..))
import PathfindingPage.Model exposing (Model)


type alias Path =
    { start : Title
    , end : Title
    , stops : List Title
    }


type alias Transition =
    Result String Path


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Transition )
update (ArticleReceived remoteArticle) model =
    case remoteArticle of
        RemoteData.NotAsked ->
            ( model, Cmd.none, Nothing )

        RemoteData.Loading ->
            ( model, Cmd.none, Nothing )

        RemoteData.Success article ->
            if article.title == model.end.title then
                ( model, Cmd.none, Just (Result.Ok (toPath model)) )
            else
                onArticleReceived article model

        RemoteData.Failure error ->
            ( model, Cmd.none, Just (Result.Err (toString error)) )


onArticleReceived : Article -> Model -> ( Model, Cmd Msg, Maybe Transition )
onArticleReceived article model =
    let
        nextModel =
            { model | stops = article.title :: model.stops }

        nextCmd =
            getNextCandidate article model
                |> Maybe.map unbox
                |> Maybe.map (requestArticle ArticleReceived)
                |> Maybe.withDefault Cmd.none
    in
        ( nextModel, nextCmd, Nothing )


toPath : Model -> Path
toPath { start, end, stops } =
    { start = start.title, end = end.title, stops = stops }
