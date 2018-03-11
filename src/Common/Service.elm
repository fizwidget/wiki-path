module Common.Service exposing (requestArticle)

import RemoteData exposing (RemoteData, WebData)
import Common.Types exposing (Article, ArticleResult, RemoteArticle, ArticleError(NetworkError))
import Common.Api


requestArticle : String -> (RemoteArticle -> msg) -> Cmd msg
requestArticle title createMsg =
    Common.Api.requestArticle title
        |> RemoteData.sendRequest
        |> Cmd.map liftResult
        |> Cmd.map createMsg


liftResult : WebData ArticleResult -> RemoteArticle
liftResult data =
    data
        |> RemoteData.mapError NetworkError
        |> RemoteData.andThen RemoteData.fromResult
