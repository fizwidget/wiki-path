module Pathfinding.Model exposing (PathfindingModel)

import Common.Article.Model exposing (Article, RemoteArticle, ArticleError)
import Common.Path.Model exposing (Path)
import Common.PriorityQueue.Model exposing (PriorityQueue)


type alias PathfindingModel =
    { source : Article
    , destination : Article
    , paths : PriorityQueue Path
    , errors : List ArticleError
    , pendingRequests : Int
    , totalRequests : Int
    }
