module Page.Pathfinding.Init exposing (init)

import Set exposing (Set)
import Data.Article exposing (Article)
import Data.Title as Title
import Data.PriorityQueue as PriorityQueue
import Data.Path as Path
import Model exposing (Model(Pathfinding))
import Messages exposing (Msg(Pathfinding))
import Page.Pathfinding.Update exposing (onArticleReceived)
import Page.Pathfinding.Model exposing (PathfindingModel)


init : Article -> Article -> ( Model, Cmd Msg )
init source destination =
    onArticleReceived
        (initialModel source destination)
        (Path.beginningWith source.title)
        source


initialModel : Article -> Article -> PathfindingModel
initialModel source destination =
    { source = source
    , destination = destination
    , paths = PriorityQueue.empty
    , visitedTitles = Set.singleton (Title.value source.title)
    , errors = []
    , pendingRequests = 0
    , totalRequests = 0
    }
