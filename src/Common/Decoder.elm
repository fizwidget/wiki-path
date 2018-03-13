module Common.Decoder exposing (decodeArticle)

import HtmlParser
import Json.Decode exposing (Decoder, map, string, oneOf)
import Json.Decode.Pipeline exposing (decode, requiredAt)
import Common.Model exposing (Article, ArticleResult, ArticleError(..))


decodeArticle : Decoder ArticleResult
decodeArticle =
    oneOf
        [ map Result.Ok decodeSuccess
        , map Result.Err decodeError
        ]


decodeSuccess : Decoder Article
decodeSuccess =
    decode fromRawContent
        |> requiredAt [ "parse", "title" ] string
        |> requiredAt [ "parse", "text" ] string


decodeError : Decoder ArticleError
decodeError =
    decode toError
        |> requiredAt [ "error", "code" ] string


toError : String -> ArticleError
toError errorCode =
    case errorCode of
        "missingtitle" ->
            ArticleNotFound

        "invalidtitle" ->
            InvalidTitle

        _ ->
            UnknownError errorCode


fromRawContent : String -> String -> Article
fromRawContent title content =
    { title = title
    , content = HtmlParser.parse content
    }
