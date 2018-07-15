module Request.Article
    exposing
        ( ArticleResult
        , RemoteArticle
        , ArticleError
            ( ArticleNotFound
            , InvalidTitle
            , UnknownError
            , HttpError
            )
        , fetchArticleResult
        , fetchRemoteArticle
        )

import Http
import RemoteData exposing (RemoteData, WebData)
import Json.Decode exposing (Decoder, field, at, map, bool, string, int, list, oneOf)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Request.Url as Url exposing (Url, QueryParam(KeyValue, Key))
import Request.Wikipedia as Wikipedia
import Request.Title as Title
import Data.Article as Article exposing (Article, Link, Namespace(ArticleNamespace, NonArticleNamespace))


type alias ArticleResult =
    Result ArticleError Article


type alias RemoteArticle =
    RemoteData ArticleError Article


type ArticleError
    = ArticleNotFound
    | InvalidTitle
    | UnknownError String
    | HttpError Http.Error


fetchArticleResult : (ArticleResult -> msg) -> String -> Cmd msg
fetchArticleResult toMsg title =
    let
        toArticleResult : Result Http.Error ArticleResult -> ArticleResult
        toArticleResult result =
            result
                |> Result.mapError HttpError
                |> Result.andThen identity
    in
        buildRequest title
            |> Http.send (toArticleResult >> toMsg)


fetchRemoteArticle : (RemoteArticle -> msg) -> String -> Cmd msg
fetchRemoteArticle toMsg title =
    let
        toRemoteArticle : WebData ArticleResult -> RemoteArticle
        toRemoteArticle webData =
            webData
                |> RemoteData.mapError HttpError
                |> RemoteData.andThen RemoteData.fromResult
    in
        buildRequest title
            |> RemoteData.sendRequest
            |> Cmd.map (toRemoteArticle >> toMsg)


buildRequest : String -> Http.Request ArticleResult
buildRequest title =
    Http.get (buildArticleUrl title) responseDecoder


buildArticleUrl : String -> Url
buildArticleUrl title =
    let
        queryParams =
            [ KeyValue ( "action", "parse" )
            , KeyValue ( "format", "json" )
            , KeyValue ( "formatversion", "2" )
            , KeyValue ( "origin", "*" )
            , KeyValue ( "page", title )
            , Key "redirects"
            ]
    in
        Url.build Wikipedia.apiBaseUrl queryParams


responseDecoder : Decoder ArticleResult
responseDecoder =
    oneOf
        [ map Ok successDecoder
        , map Err errorDecoder
        ]


successDecoder : Decoder Article
successDecoder =
    field "parse" articleDecoder


articleDecoder : Decoder Article
articleDecoder =
    decode Article
        |> required "title" Title.titleDecoder
        |> required "links" (list linkDecoder)
        |> required "text" string


linkDecoder : Decoder Link
linkDecoder =
    decode Link
        |> required "title" Title.titleDecoder
        |> required "ns" namespaceDecoder
        |> required "exists" bool


namespaceDecoder : Decoder Namespace
namespaceDecoder =
    let
        toNamespace namespaceId =
            if namespaceId == 0 then
                ArticleNamespace
            else
                NonArticleNamespace
    in
        map toNamespace int


errorDecoder : Decoder ArticleError
errorDecoder =
    let
        toError errorCode =
            case errorCode of
                "missingtitle" ->
                    ArticleNotFound

                "invalidtitle" ->
                    InvalidTitle

                _ ->
                    UnknownError errorCode

        errorCode =
            at [ "error", "code" ] string
    in
        map toError errorCode
