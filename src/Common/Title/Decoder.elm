module Common.Title.Decoder exposing (decodeTitle, decodeRandomTitlesResponse)

import Json.Decode exposing (Decoder, string, list)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Common.Title.Model as Title exposing (Title)


decodeTitle : Decoder Title
decodeTitle =
    Json.Decode.map Title.from string


type alias RandomTitlesResponse =
    List Title


decodeTitleObject : Decoder Title
decodeTitleObject =
    decode identity
        |> required "title" decodeTitle


decodeRandomTitlesResponse : Decoder RandomTitlesResponse
decodeRandomTitlesResponse =
    decode identity
        |> requiredAt [ "query", "random" ] (list decodeTitleObject)
