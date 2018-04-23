module Pathfinding.Init exposing (init)

import Common.Model.Article exposing (Article)
import Model exposing (Model(Pathfinding))
import Messages exposing (Msg(Pathfinding))
import Pathfinding.Update exposing (updateWithArticle)
import Pathfinding.Model exposing (PathfindingModel)
import Pathfinding.Model.PriorityQueue as PriorityQueue


init : Article -> Article -> ( Model, Cmd Msg )
init source destination =
    updateWithArticle
        (initialModel source destination)
        { cost = 0, next = source.title, visited = [] }
        source


initialModel : Article -> Article -> PathfindingModel
initialModel source destination =
    { source = source
    , destination = destination
    , priorityQueue = PriorityQueue.empty
    , errors = []
    , fatalError = Nothing
    }
