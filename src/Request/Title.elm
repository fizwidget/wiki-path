module Request.Title exposing (titlePair)

import Http
import RemoteData exposing (WebData)
import Json.Decode exposing (Decoder, at, list, field)
import Data.Url as Url exposing (Url, QueryParam(KeyValue, Key))
import Data.Title as Title exposing (Title, RemoteTitlePair, TitleError(HttpError, UnexpectedTitleCount))


titlePair : (RemoteTitlePair -> msg) -> Cmd msg
titlePair toMsg =
    buildRandomTitleRequest 2
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteTitlePair >> toMsg)



-- Internal


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
        Url.build baseUrl queryParams


randomTitlesResponse : Decoder (List Title)
randomTitlesResponse =
    at
        [ "query", "random" ]
        (list <| field "title" Title.decoder)
