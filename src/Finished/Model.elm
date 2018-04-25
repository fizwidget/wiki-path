module Finished.Model exposing (FinishedModel)

import Common.Title.Model exposing (Title)


type alias FinishedModel =
    { source : Title
    , destination : Title
    , stops : List Title
    }
