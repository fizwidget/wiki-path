module Common.Service exposing (getArticle)

import RemoteData exposing (RemoteData, WebData)
import Common.Model exposing (RemoteArticle, ArticleError(NetworkError), Article)
import Common.Decoder exposing (ArticleResult)
import Common.Api exposing (fetchArticle)
import Messages exposing (Msg)


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
