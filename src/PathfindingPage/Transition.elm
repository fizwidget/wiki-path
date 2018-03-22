module PathfindingPage.Transition exposing (transition)

import RemoteData
import Common.Model exposing (Title, Article, ArticleError)
import PathfindingPage.Model exposing (Model)
import PathfindingPage.Messages exposing (Msg(ArticleReceived))


type alias Path =
    { start : Title
    , end : Title
    , stops : List Title
    }


type alias Transition =
    Result String Path


transition : Msg -> Model -> Maybe Transition
transition message model =
    case message of
        ArticleReceived remoteArticle ->
            case remoteArticle of
                RemoteData.NotAsked ->
                    Nothing

                RemoteData.Loading ->
                    Nothing

                RemoteData.Success article ->
                    if article.title == model.end.title then
                        Just (Result.Ok (toPath model))
                    else
                        Nothing

                RemoteData.Failure error ->
                    Just (Result.Err (toString error))


toPath : Model -> Path
toPath { start, end, stops } =
    { start = start.title, end = end.title, stops = stops }
