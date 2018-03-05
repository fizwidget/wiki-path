module Api exposing (fetchArticle)

import Http exposing (Request)
import Model exposing (ArticleResult)
import Decoder exposing (articleResult)


fetchArticle : String -> Request ArticleResult
fetchArticle title =
    Http.get (buildUrl title) articleResult


buildUrl : String -> String
buildUrl title =
    "https://en.wikipedia.org/w/api.php?action=parse&format=json&formatversion=2&origin=*&page=" ++ title
