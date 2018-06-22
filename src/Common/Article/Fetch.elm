module Common.Article.Fetch exposing (articleResult, remoteArticle)

import Http
import RemoteData exposing (WebData)
import Common.Article.Model exposing (ArticleResult, RemoteArticle, ArticleError(HttpError))
import Common.Article.Api as Api


articleResult : (ArticleResult -> msg) -> String -> Cmd msg
articleResult toMsg title =
    Api.buildRequest title
        |> Http.send (toArticleResult >> toMsg)


remoteArticle : (RemoteArticle -> msg) -> String -> Cmd msg
remoteArticle toMsg title =
    Api.buildRequest title
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteArticle >> toMsg)


toArticleResult : Result Http.Error ArticleResult -> ArticleResult
toArticleResult result =
    result
        |> Result.mapError HttpError
        |> Result.andThen identity


toRemoteArticle : WebData ArticleResult -> RemoteArticle
toRemoteArticle webData =
    webData
        |> RemoteData.mapError Common.Article.Model.HttpError
        |> RemoteData.andThen RemoteData.fromResult
