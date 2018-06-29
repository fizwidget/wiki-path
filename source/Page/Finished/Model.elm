module Page.Finished.Model exposing (FinishedModel(Success, Error), Error(PathNotFound, TooManyRequests))

import Common.Path.Model exposing (Path)
import Common.Article.Model exposing (Article)


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
