module Pathfinding.Init exposing (init)

import Common.Model exposing (Title(Title), Article, value)
import Model exposing (Model(Pathfinding))
import Messages exposing (Msg(Pathfinding))
import Pathfinding.Update exposing (updateWithArticle)
import Pathfinding.Model exposing (PathfindingModel)


init : Article -> Article -> ( Model, Cmd Msg )
init start end =
    updateWithArticle start (initialModel start end)


initialModel : Article -> Article -> PathfindingModel
initialModel start end =
    { start = start
    , end = end
    , stops = []
    , error = Nothing
    }