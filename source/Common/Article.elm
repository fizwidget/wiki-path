module Common.Article
    exposing
        ( Article
        , Link
        , Namespace(..)
        , ArticleResult
        , RemoteArticle
        , ArticleError(..)
        , fetchArticleResult
        , fetchRemoteArticle
        , viewError
        )

import Common.Error as Error
import Common.Title as Title exposing (Title)
import Common.Url as Url exposing (Url, QueryParam(KeyValue, Key))
import Common.Wikipedia as Wikipedia
import Html.Styled exposing (Html, div, text)
import Http
import Json.Decode exposing (Decoder, field, at, map, bool, string, int, list, oneOf)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import RemoteData exposing (RemoteData)
import RemoteData exposing (WebData)


-- MODEL --


type alias Article =
    { title : Title
    , links : List Link
    , content : HtmlString
    }


type alias Link =
    { title : Title
    , namespace : Namespace
    , doesExist : Bool
    }


type Namespace
    = ArticleNamespace
    | NonArticleNamespace


type alias HtmlString =
    String


type alias ArticleResult =
    Result ArticleError Article


type alias RemoteArticle =
    RemoteData ArticleError Article


type ArticleError
    = ArticleNotFound
    | InvalidTitle
    | UnknownError String
    | HttpError Http.Error



-- API --


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
    Http.get (buildArticleUrl title) articleResponse


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



-- DECODER --


articleResponse : Decoder ArticleResult
articleResponse =
    oneOf
        [ map Ok success
        , map Err error
        ]


success : Decoder Article
success =
    field "parse" article


article : Decoder Article
article =
    decode Article
        |> required "title" Title.decoder
        |> required "links" (list link)
        |> required "text" string


link : Decoder Link
link =
    decode Link
        |> required "title" Title.decoder
        |> required "ns" namespace
        |> required "exists" bool


namespace : Decoder Namespace
namespace =
    let
        toNamespace namespaceId =
            if namespaceId == 0 then
                ArticleNamespace
            else
                NonArticleNamespace
    in
        map toNamespace int


error : Decoder ArticleError
error =
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



-- VIEW --


viewError : ArticleError -> Html msg
viewError error =
    let
        errorView =
            case error of
                ArticleNotFound ->
                    text "Couldn't find that article :("

                InvalidTitle ->
                    text "Not a valid article title :("

                UnknownError errorCode ->
                    Error.view "Unknown error \x1F92F" errorCode

                HttpError error ->
                    Error.view "Network error 😭" (toString error)
    in
        div [] [ errorView ]
