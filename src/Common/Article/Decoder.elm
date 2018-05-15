module Common.Article.Decoder exposing (decodeArticleResponse)

import Json.Decode exposing (Decoder, field, at, map, string, list, bool, oneOf)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Common.Article.Model exposing (Article, ArticleResult, ArticleError(..))
import Common.Title.Model as Title exposing (Title)
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
        |> required "links" decodeLinkTitles
        |> required "text" string


decodeLinkTitles : Decoder (List Title)
decodeLinkTitles =
    list decodeLink
        |> map (List.filter .exists)
        |> map (List.map .title)


decodeLink : Decoder Link
decodeLink =
    decode Link
        |> required "title" decodeTitle
        |> required "exists" bool


type alias Link =
    { title : Title
    , exists : Bool
    }


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
