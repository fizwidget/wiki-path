module Service exposing (getArticle)

import RemoteData exposing (RemoteData, WebData)
import Common.Model exposing (RemoteArticle, ArticleError(NetworkError), Article)
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
        |> RemoteData.mapError NetworkError
        |> RemoteData.andThen RemoteData.fromResult
