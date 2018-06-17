module Common.Title.Decoder exposing (title, randomTitlesResponse)

import Json.Decode exposing (Decoder, field, at, map, string, list)
import Common.Title.Model as Title exposing (Title)


randomTitlesResponse : Decoder (List Title)
randomTitlesResponse =
    at
        [ "query", "random" ]
        (list <| field "title" title)


title : Decoder Title
title =
    map Title.from string
