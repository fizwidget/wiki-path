module Common.Article.Api exposing (buildRequest)

import Http
import Common.Article.Model exposing (ArticleResult)
import Common.Article.Decoder exposing (decodeArticle)
import Common.Url.Model exposing (QueryParam(KeyValue, Key), buildUrl)


buildRequest : String -> Http.Request ArticleResult
buildRequest title =
    Http.get (buildArticleUrl title) decodeArticle


buildArticleUrl : String -> String
buildArticleUrl title =
    let
        baseUrl =
            "https://en.wikipedia.org/w/api.php"

        queryParams =
            [ KeyValue ( "action", "parse" )
            , Key "redirects"
            , KeyValue ( "format", "json" )
            , KeyValue ( "formatversion", "2" )
            , KeyValue ( "origin", "*" )
            , KeyValue ( "page", title )
            ]
    in
        buildUrl baseUrl queryParams
