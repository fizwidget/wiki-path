module Pathfinding.Init exposing (init)

import Common.Article.Model exposing (Article)
import Common.Title.Model exposing (Title)
import Common.PriorityQueue.Model as PriorityQueue
import Model exposing (Model(Pathfinding))
import Messages exposing (Msg(Pathfinding))
import Pathfinding.Update exposing (updateWithArticle)
import Pathfinding.Model exposing (PathfindingModel)


init : Article -> Article -> ( Model, Cmd Msg, Maybe (List Title) )
init source destination =
    updateWithArticle
        (initialModel source destination)
        { priority = 0, next = source.title, visited = [] }
        source


initialModel : Article -> Article -> PathfindingModel
initialModel source destination =
    { source = source
    , destination = destination
    , priorityQueue = PriorityQueue.empty
    , errors = []
    , fatalError = Nothing
    }
