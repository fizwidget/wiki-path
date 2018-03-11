module Pathfinding.State exposing (..)

import Pathfinding.Types
import Common.Types


type alias InitArgs =
    { source : Common.Types.Article
    , destination : Common.Types.Article
    }


init : InitArgs -> ( Pathfinding.Types.Model, Cmd Pathfinding.Types.Msg )
init initialModel =
    ( initialModel, Cmd.none )
