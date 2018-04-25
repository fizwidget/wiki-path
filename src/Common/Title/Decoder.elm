module Common.Title.Decoder exposing (decodeTitle)

import Json.Decode exposing (Decoder, string)
import Common.Title.Model as Title exposing (Title)


decodeTitle : Decoder Title
decodeTitle =
    Json.Decode.map Title.from string
