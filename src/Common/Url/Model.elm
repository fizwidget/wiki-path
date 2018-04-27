module Common.Url.Model exposing (QueryParam(KeyValue, Key), buildUrl)


buildUrl : BaseUrl -> List QueryParam -> Url
buildUrl baseUrl queryParams =
    let
        queryParamStrings =
            List.map queryParamToString queryParams

        joinedQueryParams =
            String.join "&" queryParamStrings
    in
        baseUrl ++ "?" ++ joinedQueryParams


queryParamToString : QueryParam -> String
queryParamToString queryParam =
    case queryParam of
        KeyValue ( key, value ) ->
            key ++ "=" ++ value

        Key key ->
            key


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
