module Page.Setup.Service exposing (fetchArticle)

import RemoteData exposing (WebData)
import Data.Article exposing (ArticleResult, RemoteArticle, ArticleError(HttpError))
import Request.Article as Article


fetchArticle : (RemoteArticle -> msg) -> String -> Cmd msg
fetchArticle toMsg title =
    title
        |> Article.get
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteArticle >> toMsg)


toRemoteArticle : WebData ArticleResult -> RemoteArticle
toRemoteArticle webData =
    webData
        |> RemoteData.mapError HttpError
        |> RemoteData.andThen RemoteData.fromResult
