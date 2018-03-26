module Common.Decoder exposing (decodeArticle)

import Json.Decode exposing (Decoder, map, string, list, oneOf)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Common.Model exposing (Title(Title), Article, ArticleResult, ArticleError(..))


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
        |> requiredAt [ "parse", "links" ] decodeLinks


decodeLinks : Decoder (List Title)
decodeLinks =
    list decodeLink


decodeLink : Decoder Title
decodeLink =
    decode Title
        |> required "title" string


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


fromRawContent : String -> String -> List Title -> Article
fromRawContent title content links =
    { title = Title title
    , content = content
    , links = links
    }
