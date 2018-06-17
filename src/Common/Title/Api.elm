module Common.Title.Api exposing (buildRandomTitleRequest)

import Http
import Common.Url.Model exposing (Url, QueryParam(KeyValue, Key), buildUrl)
import Common.Wikipedia.Api as Wikipedia
import Common.Title.Model exposing (Title)
import Common.Title.Decoder as Decoder


buildRandomTitleRequest : Int -> Http.Request (List Title)
buildRandomTitleRequest titleCount =
    Http.get (buildRandomTitlesUrl titleCount) Decoder.randomTitlesResponse


buildRandomTitlesUrl : Int -> Url
buildRandomTitlesUrl titleCount =
    let
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
        buildUrl Wikipedia.apiBaseUrl queryParams
