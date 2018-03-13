module Messages exposing (..)

import Setup.Messages
import Pathfinding.Messages
import Finished.Messages


type Msg
    = SetupMsg Setup.Messages.Msg
    | PathfindingMsg Pathfinding.Messages.Msg
    | FinishedMsg Finished.Messages.Msg
