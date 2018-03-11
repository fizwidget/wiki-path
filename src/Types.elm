module Types exposing (..)

import Setup.Types
import Pathfinding.Types
import Finished.Types


type Msg
    = SetupMsg Setup.Types.Msg
    | PathfindingMsg Pathfinding.Types.Msg
    | FinishedMsg Finished.Types.Msg


type Model
    = Setup Setup.Types.Model
    | Pathfinding Pathfinding.Types.Model
    | Finished Finished.Types.Model
