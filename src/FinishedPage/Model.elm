module FinishedPage.Model exposing (FinishedModel)

import Common.Model exposing (Title)


type alias FinishedModel =
    { start : Title
    , end : Title
    , stops : List Title
    }
