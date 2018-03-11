module Common.Decoder exposing (decodeArticle)

import HtmlParser
import Json.Decode exposing (Decoder, map, string, oneOf)
import Json.Decode.Pipeline exposing (decode, requiredAt)
import Common.Types exposing (Article, ArticleResult, ArticleError(ArticleNotFound, UnknownError))


decodeArticle : Decoder ArticleResult
decodeArticle =
    oneOf
        [ map Result.Ok article
        , map Result.Err error
        ]


article : Decoder Article
article =
    decode buildArticle
        |> requiredAt [ "parse", "title" ] string
        |> requiredAt [ "parse", "text" ] string


buildArticle : String -> String -> Article
buildArticle title content =
    { title = title
    , content = HtmlParser.parse content
    }


error : Decoder ArticleError
error =
    decode toError
        |> requiredAt [ "error", "code" ] string


toError : String -> ArticleError
toError errorCode =
    case errorCode of
        "missingtitle" ->
            ArticleNotFound

        _ ->
            UnknownError errorCode
