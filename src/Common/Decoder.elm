module Common.Decoder exposing (decodeArticle)

import Json.Decode exposing (Decoder, map, string, list, bool, oneOf)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Common.Model.Article exposing (Article, ArticleResult, ArticleError(..))
import Common.Model.Title as Title exposing (Title)


decodeArticle : Decoder ArticleResult
decodeArticle =
    oneOf
        [ map Result.Ok decodeSuccess
        , map Result.Err decodeError
        ]


decodeSuccess : Decoder Article
decodeSuccess =
    decode Article
        |> requiredAt [ "parse", "title" ] decodeTitle
        |> requiredAt [ "parse", "links" ] decodeLinks
        |> requiredAt [ "parse", "text" ] string


decodeTitle : Decoder Title
decodeTitle =
    Json.Decode.map Title.from string


decodeLinks : Decoder (List Title)
decodeLinks =
    Json.Decode.map (List.filterMap identity) (list decodeExistingLink)


decodeExistingLink : Decoder (Maybe Title)
decodeExistingLink =
    Json.Decode.map
        (\link ->
            if link.exists then
                Just link.title
            else
                Nothing
        )
        decodeLink


type alias Link =
    { title : Title
    , exists : Bool
    }


decodeLink : Decoder Link
decodeLink =
    decode Link
        |> required "title" decodeTitle
        |> required "exists" bool


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
