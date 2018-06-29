module Page.Pathfinding.Model exposing (PathfindingModel)

import Set exposing (Set)
import Common.Article.Model exposing (Article, RemoteArticle, ArticleError)
import Common.Path.Model exposing (Path)
import Common.PriorityQueue.Model exposing (PriorityQueue)


type alias PathfindingModel =
    { source : Article
    , destination : Article
    , paths : PriorityQueue Path
    , visitedTitles : Set String
    , errors : List ArticleError
    , pendingRequests : Int
    , totalRequests : Int
    }
