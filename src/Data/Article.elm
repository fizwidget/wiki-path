module Data.Article
    exposing
        ( Article
        , Link
        , Namespace(..)
        , ArticleResult
        , RemoteArticle
        , ArticleError(..)
        , decoder
        , errorDecoder
        )

import Http
import RemoteData exposing (RemoteData)
import Json.Decode exposing (Decoder, field, at, map, bool, string, int, list, oneOf)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Data.Title as Title exposing (Title)


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



-- Serialisation


decoder : Decoder Article
decoder =
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


errorDecoder : Decoder ArticleError
errorDecoder =
    let
        toError errorCode =
            case errorCode of
                "missingtitle" ->
                    ArticleNotFound

                "invalidtitle" ->
                    InvalidTitle

                _ ->
                    UnknownError errorCode
    in
        map toError string
