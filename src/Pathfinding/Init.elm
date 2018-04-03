module Pathfinding.Init exposing (init)

import Common.Model exposing (Title(Title), Article, value)
import Model exposing (Model(Pathfinding))
import Messages exposing (Msg(Pathfinding))
import Pathfinding.Update exposing (onArticleSuccess)
import Pathfinding.Model exposing (PathfindingModel)


init : Article -> Article -> ( Model, Cmd Msg )
init start end =
    onArticleSuccess (initialModel start end) start


initialModel : Article -> Article -> PathfindingModel
initialModel start end =
    { start = start
    , end = end
    , stops = [ start.title ]
    , error = Nothing
    }
