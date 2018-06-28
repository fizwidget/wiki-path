module Page.Pathfinding.Model exposing (PathfindingModel)

import Set exposing (Set)
import Data.Article exposing (Article, RemoteArticle, ArticleError)
import Data.Path exposing (Path)
import Data.PriorityQueue exposing (PriorityQueue)


type alias PathfindingModel =
    { source : Article
    , destination : Article
    , paths : PriorityQueue Path
    , visitedTitles : Set String
    , errors : List ArticleError
    , pendingRequests : Int
    , totalRequests : Int
    }
