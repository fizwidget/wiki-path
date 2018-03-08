module Service exposing (getArticle)

import Http
import RemoteData exposing (RemoteData, WebData)
import Model exposing (RemoteArticle, ArticleError(NetworkError), Article)
import Messages exposing (Msg)
import Decoder exposing (ArticleResult)
import Api exposing (fetchArticle)


getArticle : String -> (RemoteArticle -> Msg) -> Cmd Msg
getArticle title createMsg =
    fetchArticle title
        |> RemoteData.sendRequest
        |> Cmd.map liftResult
        |> Cmd.map createMsg


liftResult : WebData ArticleResult -> RemoteArticle
liftResult data =
    data
        |> RemoteData.mapError liftError
        |> RemoteData.andThen (\result -> RemoteData.fromResult result)


liftError : Http.Error -> ArticleError
liftError httpError =
    NetworkError httpError
