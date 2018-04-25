module Common.Url.Model exposing (QueryParam(WithValue, WithNoValue), buildUrl)


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
        WithValue ( name, value ) ->
            name ++ "=" ++ value

        WithNoValue name ->
            name


type QueryParam
    = WithValue ( QueryParamName, QueryParamValue )
    | WithNoValue QueryParamName


type alias BaseUrl =
    String


type alias QueryParamName =
    String


type alias QueryParamValue =
    String


type alias Url =
    String
