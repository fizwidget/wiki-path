module Pathfinding.Model exposing (PathfindingModel, Path, Cost, Error(..))

import PairingHeap exposing (PairingHeap)
import Common.Model.Title exposing (Title)
import Common.Model.Article exposing (Article, RemoteArticle, ArticleError)


type alias PathfindingModel =
    { source : Article
    , destination : Article
    , priorityQueue : PairingHeap Cost Path
    , error : Maybe Error
    }


type alias Cost =
    Int


type alias Path =
    { next : Title
    , visited : List Title
    }


type Error
    = PathNotFound Title
    | ArticleError ArticleError
