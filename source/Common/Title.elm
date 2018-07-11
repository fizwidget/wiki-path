module Common.Title
    exposing
        ( Title
        , RemoteTitlePair
        , TitleError(..)
        , from
        , value
        , fetchPair
        , decoder
        , viewAsLink
        )

import Common.Url as Url exposing (Url, QueryParam(KeyValue, Key))
import Json.Decode exposing (Decoder, field, at, map, string, list)
import Common.Wikipedia as Wikipedia
import Html.Styled exposing (Html, text, a)
import Html.Styled.Attributes exposing (href)
import Http
import RemoteData exposing (RemoteData, WebData)


-- MODEL --


type Title
    = Title String


from : String -> Title
from =
    Title


value : Title -> String
value (Title title) =
    title


type alias RemoteTitlePair =
    RemoteData TitleError ( Title, Title )


type TitleError
    = UnexpectedTitleCount
    | HttpError Http.Error



-- API --


fetchPair : (RemoteTitlePair -> msg) -> Cmd msg
fetchPair toMsg =
    buildRandomTitleRequest 2
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteTitlePair >> toMsg)


toRemoteTitlePair : WebData (List Title) -> RemoteTitlePair
toRemoteTitlePair remoteTitles =
    let
        toPair titles =
            case titles of
                titleA :: titleB :: _ ->
                    RemoteData.succeed ( titleA, titleB )

                _ ->
                    RemoteData.Failure UnexpectedTitleCount
    in
        remoteTitles
            |> RemoteData.mapError HttpError
            |> RemoteData.andThen toPair


buildRandomTitleRequest : Int -> Http.Request (List Title)
buildRandomTitleRequest titleCount =
    Http.get (buildRandomTitlesUrl titleCount) randomTitlesResponse


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
        Url.build Wikipedia.apiBaseUrl queryParams



-- DECODER --


randomTitlesResponse : Decoder (List Title)
randomTitlesResponse =
    at
        [ "query", "random" ]
        (list <| field "title" decoder)


decoder : Decoder Title
decoder =
    map from string



-- VIEW --


viewAsLink : Title -> Html msg
viewAsLink title =
    a
        [ href (toUrl title) ]
        [ text (value title) ]


toUrl : Title -> String
toUrl title =
    "https://en.wikipedia.org/wiki/" ++ (value title)
