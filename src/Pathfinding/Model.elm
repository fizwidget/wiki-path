module Pathfinding.Model exposing (PathfindingModel, Error(PathNotFound, TooManyRequests))

import Common.Article.Model exposing (Article, RemoteArticle, ArticleError)
import Common.Path.Model exposing (Path)
import Common.PriorityQueue.Model exposing (PriorityQueue)


type alias PathfindingModel =
    { source : Article
    , destination : Article
    , priorityQueue : PriorityQueue Path
    , errors : List ArticleError
    , fatalError : Maybe Error
    , inFlightRequests : Int
    , totalRequestCount : Int
    }


type Error
    = PathNotFound
    | TooManyRequests
