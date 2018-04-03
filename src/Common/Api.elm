module Common.Api exposing (requestArticle)

import Http
import Common.Model.Article exposing (ArticleResult)
import Common.Decoder exposing (decodeArticle)


requestArticle : String -> Http.Request ArticleResult
requestArticle title =
    Http.get (buildUrl title) decodeArticle


buildUrl : String -> String
buildUrl title =
    "https://en.wikipedia.org/w/api.php?action=parse&format=json&formatversion=2&origin=*&page=" ++ title
