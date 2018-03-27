module Messages exposing (Msg(..))

import Welcome.Messages exposing (WelcomeMsg)
import Pathfinding.Messages exposing (PathfindingMsg)
import Finished.Messages exposing (FinishedMsg)


type Msg
    = Welcome WelcomeMsg
    | Pathfinding PathfindingMsg
    | Finished FinishedMsg
