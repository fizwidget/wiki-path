module Pathfinding.Fetch exposing (article)

import Http
import Common.Article.Model exposing (ArticleResult, ArticleError(HttpError))
import Common.Article.Api as ArticleApi


article : (ArticleResult -> msg) -> String -> Cmd msg
article toMsg title =
    ArticleApi.buildRequest title
        |> Http.send (toArticleResult >> toMsg)


toArticleResult : Result Http.Error ArticleResult -> ArticleResult
toArticleResult result =
    result
        |> Result.mapError HttpError
        |> Result.andThen identity
