module Common.Title.Api exposing (buildRandomTitleRequest)

import Http
import Common.Url.Model exposing (Url, QueryParam(KeyValue, Key), buildUrl)
import Common.Title.Model exposing (Title)
import Common.Title.Decoder exposing (decodeRandomTitlesResponse)


buildRandomTitleRequest : Int -> Http.Request (List Title)
buildRandomTitleRequest titleCount =
    Http.get (buildRandomTitlesUrl titleCount) decodeRandomTitlesResponse


buildRandomTitlesUrl : Int -> Url
buildRandomTitlesUrl titleCount =
    let
        baseUrl =
            "https://en.wikipedia.org/w/api.php"

        articleNamespace =
            "0"

        queryParams =
            [ KeyValue ( "action", "query" )
            , KeyValue ( "format", "json" )
            , KeyValue ( "list", "random" )
            , KeyValue ( "rnlimit", toString titleCount )
            , KeyValue ( "rnnamespace", articleNamespace )
            , KeyValue ( "origin", "*" )
            ]
    in
        buildUrl baseUrl queryParams
