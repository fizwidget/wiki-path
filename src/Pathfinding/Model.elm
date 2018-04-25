module Pathfinding.Model exposing (PathfindingModel, Path, Error(PathNotFound))

import Common.Title.Model exposing (Title)
import Common.Article.Model exposing (Article, RemoteArticle, ArticleError)
import Common.PriorityQueue.Model exposing (PriorityQueue, Priority)


type alias PathfindingModel =
    { source : Article
    , destination : Article
    , priorityQueue : PriorityQueue Path
    , errors : List ArticleError
    , fatalError : Maybe Error
    }


type alias Path =
    { priority : Priority
    , next : Title
    , visited : List Title
    }


type Error
    = PathNotFound
