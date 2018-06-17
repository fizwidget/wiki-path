module Common.Article.Api exposing (buildRequest)

import Http
import Common.Url.Model exposing (Url, QueryParam(KeyValue, Key), buildUrl)
import Common.Wikipedia.Api as Wikipedia
import Common.Article.Model exposing (ArticleResult)
import Common.Article.Decoder as Decoder


buildRequest : String -> Http.Request ArticleResult
buildRequest title =
    Http.get (buildArticleUrl title) Decoder.articleResponse


buildArticleUrl : String -> Url
buildArticleUrl title =
    let
        queryParams =
            [ KeyValue ( "action", "parse" )
            , KeyValue ( "format", "json" )
            , KeyValue ( "formatversion", "2" )
            , KeyValue ( "origin", "*" )
            , KeyValue ( "page", title )
            , Key "redirects"
            ]
    in
        buildUrl Wikipedia.apiBaseUrl queryParams
