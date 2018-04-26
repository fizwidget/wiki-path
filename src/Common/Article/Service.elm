module Common.Article.Service exposing (requestRemote, request)

import Http
import RemoteData exposing (RemoteData, WebData)
import Common.Article.Model exposing (Article, ArticleResult, RemoteArticle, ArticleError(NetworkError))
import Common.Article.Api as ArticleApi


request : (ArticleResult -> msg) -> String -> Cmd msg
request toMsg title =
    ArticleApi.buildRequest title
        |> Http.send (toArticleResult >> toMsg)


requestRemote : (RemoteArticle -> msg) -> String -> Cmd msg
requestRemote toMsg title =
    ArticleApi.buildRequest title
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteArticle >> toMsg)


toArticleResult : Result Http.Error ArticleResult -> ArticleResult
toArticleResult result =
    result
        |> Result.mapError NetworkError
        |> Result.andThen identity


toRemoteArticle : WebData ArticleResult -> RemoteArticle
toRemoteArticle webData =
    webData
        |> RemoteData.mapError NetworkError
        |> RemoteData.andThen RemoteData.fromResult
