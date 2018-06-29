module Request.Article exposing (get)

import Http
import Json.Decode exposing (Decoder, map, oneOf, field, at)
import Data.Url as Url exposing (Url, QueryParam(KeyValue, Key))
import Data.Article as Article exposing (ArticleResult, RemoteArticle, ArticleError(HttpError))


get : String -> Http.Request ArticleResult
get title =
    Http.get (articleUrl title) responseDecoder


articleUrl : String -> Url
articleUrl title =
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
        Url.build baseUrl queryParams


responseDecoder : Decoder ArticleResult
responseDecoder =
    let
        success =
            field "parse" Article.decoder

        error =
            at [ "error", "code" ] Article.errorDecoder
    in
        oneOf [ map Ok success, map Err error ]
