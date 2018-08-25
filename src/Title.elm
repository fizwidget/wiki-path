module Title exposing (Title, RemoteTitlePair, from, asString, getRandomPair, titleDecoder, viewAsLink)

import Http
import RemoteData exposing (RemoteData, WebData)
import Json.Decode exposing (Decoder, field, at, map, string, list)
import Html.Styled exposing (Html, a, text)
import Html.Styled.Attributes exposing (href)
import Url exposing (Url, QueryParam(KeyValue, Key))


type Title
    = Title String


from : String -> Title
from =
    Title


asString : Title -> String
asString (Title title) =
    title



-- VIEW


viewAsLink : Title -> Html msg
viewAsLink title =
    a
        [ href (toUrl title) ]
        [ text (asString title) ]


toUrl : Title -> String
toUrl title =
    "https://en.wikipedia.org/wiki/" ++ (asString title)



-- API


type alias RemoteTitlePair =
    RemoteData TitleError ( Title, Title )


type TitleError
    = UnexpectedTitleCount
    | HttpError Http.Error


getRandomPair : (RemoteTitlePair -> msg) -> Cmd msg
getRandomPair toMsg =
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
    Http.get (buildRandomTitlesUrl titleCount) randomTitlesResponseDecoder


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
        Url.build "https://en.wikipedia.org/w/api.php" queryParams



-- SERIALIZATION


randomTitlesResponseDecoder : Decoder (List Title)
randomTitlesResponseDecoder =
    at
        [ "query", "random" ]
        (list <| field "title" titleDecoder)


titleDecoder : Decoder Title
titleDecoder =
    map from string
