module Pathfinding.Model exposing (PathfindingModel, Error(..))

import Common.Model.Title exposing (Title)
import Common.Model.Article exposing (Article, RemoteArticle, ArticleError)


type alias PathfindingModel =
    { start : Article
    , end : Article
    , stops : List Title
    , error : Maybe Error
    }


type Error
    = PathNotFound Title
    | ArticleError ArticleError
