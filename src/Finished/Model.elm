module Finished.Model exposing (FinishedModel(Success, Error), Error(PathNotFound, TooManyRequests))

import Common.Path.Model exposing (Path)


type FinishedModel
    = Success Path
    | Error Error


type Error
    = PathNotFound
    | TooManyRequests
