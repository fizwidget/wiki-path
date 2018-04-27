module Messages exposing (Msg(..))

import Setup.Messages exposing (SetupMsg)
import Pathfinding.Messages exposing (PathfindingMsg)


type Msg
    = Setup SetupMsg
    | Pathfinding PathfindingMsg
    | ToSetup
