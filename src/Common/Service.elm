module Common.Service exposing (requestArticle)

import RemoteData exposing (RemoteData, WebData)
import Common.Model exposing (Article, ArticleResult, RemoteArticle, ArticleError(NetworkError))
import Common.Api


requestArticle : (RemoteArticle -> msg) -> String -> Cmd msg
requestArticle tagger title =
    Common.Api.requestArticle title
        |> RemoteData.sendRequest
        |> Cmd.map toRemoteArticle
        |> Cmd.map tagger


toRemoteArticle : WebData ArticleResult -> RemoteArticle
toRemoteArticle data =
    data
        |> RemoteData.mapError NetworkError
        |> RemoteData.andThen RemoteData.fromResult
