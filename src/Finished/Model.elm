module Finished.Model exposing (FinishedModel)

import Common.Model.Title exposing (Title)


type alias FinishedModel =
    { source : Title
    , destination : Title
    , stops : List Title
    }
