module Pathfinding.Model exposing (PathfindingModel, Path, , Error(..))

import PairingHeap exposing (PairingHeap)
import Common.Model.Title exposing (Title)
import Common.Model.Article exposing (Article, RemoteArticle, ArticleError)


type alias Cost =
    Int


type alias Path =
    List Title


type alias PathfindingModel =
    { source : Article
    , destination : Article
    , priorityQueue : PairingHeap Cost Path
    , error : Maybe Error
    }


type Error
    = PathNotFound Title
    | ArticleError ArticleError
