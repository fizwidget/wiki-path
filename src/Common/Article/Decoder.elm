module Common.Article.Decoder exposing (decodeArticleResponse)

import Json.Decode exposing (Decoder, field, at, map, bool, string, int, list, oneOf)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Common.Article.Model exposing (Article, Link, Namespace(..), ArticleResult, ArticleError(..))
import Common.Title.Decoder exposing (decodeTitle)


decodeArticleResponse : Decoder ArticleResult
decodeArticleResponse =
    oneOf
        [ map Ok decodeSuccess
        , map Err decodeError
        ]


decodeSuccess : Decoder Article
decodeSuccess =
    field "parse" decodeArticle


decodeArticle : Decoder Article
decodeArticle =
    decode Article
        |> required "title" decodeTitle
        |> required "links" (list decodeLink)
        |> required "text" string


decodeLink : Decoder Link
decodeLink =
    decode Link
        |> required "title" decodeTitle
        |> required "ns" decodeNamespace
        |> required "exists" bool


decodeNamespace : Decoder Namespace
decodeNamespace =
    map fromNamespaceId int


fromNamespaceId : Int -> Namespace
fromNamespaceId namespaceId =
    if namespaceId == 0 then
        ArticleNamespace
    else
        NonArticleNamespace


decodeError : Decoder ArticleError
decodeError =
    at [ "error", "code" ] string
        |> map fromErrorCode


fromErrorCode : String -> ArticleError
fromErrorCode errorCode =
    case errorCode of
        "missingtitle" ->
            ArticleNotFound

        "invalidtitle" ->
            InvalidTitle

        _ ->
            UnknownError errorCode
