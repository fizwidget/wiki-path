module Common.Service exposing (requestRemoteArticle, requestArticleResult)

import Http
import RemoteData exposing (RemoteData, WebData)
import Common.Model.Article exposing (Article, ArticleResult, RemoteArticle, ArticleError(NetworkError))
import Common.Api


requestRemoteArticle : (RemoteArticle -> msg) -> String -> Cmd msg
requestRemoteArticle tagger title =
    Common.Api.requestArticle title
        |> RemoteData.sendRequest
        |> Cmd.map toRemoteArticle
        |> Cmd.map tagger



-- requestRemoteArticleWithRedirectResolution : (RemoteArticle -> msg) -> String -> Cmd msg
-- requestRemoteArticleWithRedirectResolution tagger title =
--     let
--         resolveRedirect =
--             Debug.crash "Uh oh"
--     in
--         Common.Api.requestArticle title
--             |> RemoteData.sendRequest
--             |> RemoteData.andThen resolveRedirect
--             |> Cmd.map toRemoteArticle
--             |> Cmd.map tagger


toRemoteArticle : WebData ArticleResult -> RemoteArticle
toRemoteArticle data =
    data
        |> RemoteData.mapError NetworkError
        |> RemoteData.andThen RemoteData.fromResult


requestArticleResult : (ArticleResult -> msg) -> String -> Cmd msg
requestArticleResult tagger title =
    Common.Api.requestArticle title
        |> Http.send (tagger << toArticleResult)


toArticleResult : Result Http.Error ArticleResult -> ArticleResult
toArticleResult result =
    result
        |> Result.mapError NetworkError
        |> Result.andThen identity
