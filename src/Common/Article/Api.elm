module Common.Article.Api exposing (buildRequest)

import Http
import Common.Article.Model exposing (ArticleResult)
import Common.Article.Decoder exposing (decodeArticleResponse)
import Common.Url.Model exposing (Url, QueryParam(KeyValue, Key), buildUrl)


buildRequest : String -> Http.Request ArticleResult
buildRequest title =
    Http.get (buildArticleUrl title) decodeArticleResponse


buildArticleUrl : String -> Url
buildArticleUrl title =
    let
        baseUrl =
            "https://en.wikipedia.org/w/api.php"

        queryParams =
            [ KeyValue ( "action", "parse" )
            , KeyValue ( "format", "json" )
            , KeyValue ( "formatversion", "2" )
            , KeyValue ( "origin", "*" )
            , KeyValue ( "page", title )
            , Key "redirects"
            ]
    in
        buildUrl baseUrl queryParams
