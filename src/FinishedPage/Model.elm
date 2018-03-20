module FinishedPage.Model exposing (..)

import Common.Model exposing (Title, Article)


type alias Path =
    { source : Article
    , destination : Article
    , path : List Title
    }


type alias Model =
    Result String Path
