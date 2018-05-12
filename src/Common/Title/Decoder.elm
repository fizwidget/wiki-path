module Common.Title.Decoder exposing (decodeTitle, decodeRandomTitlesResponse)

import Json.Decode exposing (Decoder, field, at, map, string, list)
import Common.Title.Model as Title exposing (Title)


decodeTitle : Decoder Title
decodeTitle =
    map Title.from string


decodeRandomTitlesResponse : Decoder (List Title)
decodeRandomTitlesResponse =
    at
        [ "query", "random" ]
        (list <| field "title" decodeTitle)
