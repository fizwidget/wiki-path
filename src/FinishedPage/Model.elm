module FinishedPage.Model exposing (..)

import Common.Model exposing (Title)


type alias Path =
    { start : Title
    , end : Title
    , stops : List Title
    }


type alias Model =
    Path
