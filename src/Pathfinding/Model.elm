module Pathfinding.Model exposing (PathfindingModel, Path, Error(PathNotFound))

import Set exposing (Set)
import Common.Model.Title exposing (Title)
import Common.Model.Article exposing (Article, RemoteArticle, ArticleError)
import Pathfinding.Model.PriorityQueue exposing (PriorityQueue, Priority)


type alias PathfindingModel =
    { source : Article
    , destination : Article
    , priorityQueue : PriorityQueue Path
    , visitedTitles : Set String
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
