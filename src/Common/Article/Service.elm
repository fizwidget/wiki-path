module Common.Article.Service exposing (requestRemoteArticle, requestArticleResult)

import Http
import RemoteData exposing (RemoteData, WebData)
import Common.Article.Model exposing (Article, ArticleResult, RemoteArticle, ArticleError(NetworkError))
import Common.Article.Api as Api


requestRemoteArticle : (RemoteArticle -> msg) -> String -> Cmd msg
requestRemoteArticle tagger title =
    Api.requestArticle title
        |> RemoteData.sendRequest
        |> Cmd.map toRemoteArticle
        |> Cmd.map tagger


toRemoteArticle : WebData ArticleResult -> RemoteArticle
toRemoteArticle data =
    data
        |> RemoteData.mapError NetworkError
        |> RemoteData.andThen RemoteData.fromResult


requestArticleResult : (ArticleResult -> msg) -> String -> Cmd msg
requestArticleResult tagger title =
    Api.requestArticle title
        |> Http.send (tagger << toArticleResult)


toArticleResult : Result Http.Error ArticleResult -> ArticleResult
toArticleResult result =
    result
        |> Result.mapError NetworkError
        |> Result.andThen identity
