module Messages exposing (Msg(..))

import Page.Setup.Messages exposing (SetupMsg)
import Page.Pathfinding.Messages exposing (PathfindingMsg)
import Page.Finished.Messages exposing (FinishedMsg)


type Msg
    = Setup SetupMsg
    | Pathfinding PathfindingMsg
    | Finished FinishedMsg
