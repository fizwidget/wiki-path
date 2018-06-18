module Common.Article.Decoder exposing (articleResponse)

import Json.Decode exposing (Decoder, field, at, map, bool, string, int, list, oneOf)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Common.Article.Model exposing (Article, Link, Namespace(..), ArticleResult, ArticleError(..))
import Common.Title.Decoder exposing (title)


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
        |> required "title" title
        |> required "links" (list link)
        |> required "text" string


link : Decoder Link
link =
    decode Link
        |> required "title" title
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
