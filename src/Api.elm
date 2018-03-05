module Api exposing (fetchArticle)

import Http exposing (Request)
import Model exposing (ArticleResult)
import Decoder exposing (remoteArticle)


fetchArticle : String -> Request ArticleResult
fetchArticle title =
    Http.get (buildUrl title) remoteArticle


buildUrl : String -> String
buildUrl title =
    "https://en.wikipedia.org/w/api.php?action=parse&format=json&formatversion=2&origin=*&page=" ++ title
