module Common.Url exposing (QueryParam(WithValue, WithNoValue), buildUrl)


buildUrl : BaseUrl -> List QueryParam -> Url
buildUrl baseUrl queryParams =
    queryParams
        |> List.map queryParamToString
        |> String.join "&"
        |> String.append (baseUrl ++ "?")


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
