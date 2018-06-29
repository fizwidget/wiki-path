module Page.Pathfinding.Service exposing (fetchArticle)

import Http
import Data.Article exposing (ArticleResult, ArticleError(HttpError))
import Request.Article as Article


fetchArticle : (ArticleResult -> msg) -> String -> Cmd msg
fetchArticle toMsg title =
    title
        |> Article.get
        |> Http.send (toArticleResult >> toMsg)


toArticleResult : Result Http.Error ArticleResult -> ArticleResult
toArticleResult result =
    result
        |> Result.mapError HttpError
        |> Result.andThen identity
