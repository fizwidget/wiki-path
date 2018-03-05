module Decoder exposing (articleResult)

import Json.Decode exposing (Decoder, map, string, oneOf)
import Json.Decode.Pipeline exposing (decode, requiredAt)
import HtmlParser exposing (parse)
import Model exposing (ArticleResult, Article, ApiError(..))


articleResult : Decoder ArticleResult
articleResult =
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
    , content = parse content
    }


error : Decoder ApiError
error =
    decode toError
        |> requiredAt [ "error", "code" ] string


toError : String -> ApiError
toError errorCode =
    case errorCode of
        "missingtitle" ->
            ArticleNotFound

        _ ->
            UnknownError errorCode
