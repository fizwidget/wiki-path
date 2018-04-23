module Pathfinding.Model exposing (PathfindingModel, Path, Cost, PathPriorityQueue, Error(PathNotFound))

import Common.Model.Title exposing (Title)
import Common.Model.Article exposing (Article, RemoteArticle, ArticleError)
import Pathfinding.Model.PriorityQueue exposing (PriorityQueue)


type alias PathfindingModel =
    { source : Article
    , destination : Article
    , priorityQueue : PathPriorityQueue
    , errors : List ArticleError
    , fatalError : Maybe Error
    }


type alias PathPriorityQueue =
    PriorityQueue Cost Path


type alias Cost =
    Float


type alias Path =
    { cost : Cost
    , next : Title
    , visited : List Title
    }


type Error
    = PathNotFound
