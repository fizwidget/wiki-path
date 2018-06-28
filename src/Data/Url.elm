module Data.Url exposing (Url, QueryParam(KeyValue, Key), build)

import Http


build : BaseUrl -> List QueryParam -> Url
build baseUrl queryParams =
    let
        queryParamStrings =
            List.map encode queryParams

        joinedQueryParams =
            String.join "&" queryParamStrings
    in
        baseUrl ++ "?" ++ joinedQueryParams


encode : QueryParam -> String
encode queryParam =
    case queryParam of
        KeyValue ( key, value ) ->
            (Http.encodeUri key) ++ "=" ++ (Http.encodeUri value)

        Key key ->
            Http.encodeUri key


type QueryParam
    = KeyValue ( QueryParamName, QueryParamValue )
    | Key QueryParamName


type alias BaseUrl =
    String


type alias QueryParamName =
    String


type alias QueryParamValue =
    String


type alias Url =
    String
