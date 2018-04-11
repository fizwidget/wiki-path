module Messages exposing (Msg(..))

import Setup.Messages exposing (SetupMsg)
import Pathfinding.Messages exposing (PathfindingMsg)
import Finished.Messages exposing (FinishedMsg)


type Msg
    = Setup SetupMsg
    | Pathfinding PathfindingMsg
    | Finished FinishedMsg
