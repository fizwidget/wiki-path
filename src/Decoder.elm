module Decoder exposing (remoteArticle)

import Json.Decode exposing (Decoder, map, string, oneOf)
import Json.Decode.Pipeline exposing (decode, requiredAt)
import Model.Main exposing (ArticleResult, ApiError(..))


type alias RawArticle =
    { title : String
    , description : String
    }


remoteArticle : Decoder (Result ApiError RawArticle)
remoteArticle =
    oneOf
        [ map Result.Ok article
        , map Result.Err error
        ]


article : Decoder RawArticle
article =
    decode RawArticle
        |> requiredAt [ "parse", "title" ] string
        |> requiredAt [ "parse", "text" ] string


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
