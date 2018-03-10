module Common.Decoder exposing (ArticleResult, articleResult)

import Json.Decode exposing (Decoder, map, string, oneOf)
import Json.Decode.Pipeline exposing (decode, requiredAt)
import HtmlParser exposing (parse)
import Common.Model exposing (Article, ArticleError(ArticleNotFound, UnknownError))


type alias ArticleResult =
    Result ArticleError Article


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
