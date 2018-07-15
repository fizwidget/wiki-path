module Request.Title
    exposing
        ( RemoteTitlePair
        , TitleError(UnexpectedTitleCount, HttpError)
        , fetchPair
        , titleDecoder
        )

import Http
import RemoteData exposing (RemoteData, WebData)
import Json.Decode exposing (Decoder, field, at, map, string, list)
import Request.Url as Url exposing (Url, QueryParam(KeyValue, Key))
import Request.Wikipedia as Wikipedia
import Data.Title as Title exposing (Title)


type alias RemoteTitlePair =
    RemoteData TitleError ( Title, Title )


type TitleError
    = UnexpectedTitleCount
    | HttpError Http.Error


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
        Url.build Wikipedia.apiBaseUrl queryParams


randomTitlesResponseDecoder : Decoder (List Title)
randomTitlesResponseDecoder =
    at
        [ "query", "random" ]
        (list <| field "title" titleDecoder)


titleDecoder : Decoder Title
titleDecoder =
    map Title.from string
