module Pathfinding.Init exposing (init)

import Set exposing (Set)
import Common.Article.Model exposing (Article)
import Common.PriorityQueue.Model as PriorityQueue
import Common.Path.Model as Path
import Model exposing (Model(Pathfinding))
import Messages exposing (Msg(Pathfinding))
import Pathfinding.Update exposing (updateWithResult)
import Pathfinding.Model exposing (PathfindingModel)


init : Article -> Article -> ( Model, Cmd Msg )
init source destination =
    updateWithResult
        (initialModel source destination)
        (Path.beginningWith source.title)
        (Result.Ok source)


initialModel : Article -> Article -> PathfindingModel
initialModel source destination =
    { source = source
    , destination = destination
    , paths = PriorityQueue.empty
    , visitedTitles = Set.empty
    , errors = []
    , pendingRequests = 0
    , totalRequests = 0
    }
