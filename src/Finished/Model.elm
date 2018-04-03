module Finished.Model exposing (FinishedModel)

import Common.Model.Title exposing (Title)


type alias FinishedModel =
    { start : Title
    , end : Title
    , stops : List Title
    }
