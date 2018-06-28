module Page.Finished.Model exposing (FinishedModel(Success, Error), Error(PathNotFound, TooManyRequests))

import Data.Path exposing (Path)
import Data.Article exposing (Article)


type FinishedModel
    = Success Path
    | Error
        { source : Article
        , destination : Article
        , error : Error
        }


type Error
    = PathNotFound
    | TooManyRequests
