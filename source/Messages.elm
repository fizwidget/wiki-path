module Messages exposing (Msg(..))

import Page.Setup as Setup
import Page.Pathfinding.Messages exposing (PathfindingMsg)
import Page.Finished.Messages exposing (FinishedMsg)


type Msg
    = Setup Setup.Msg
    | Pathfinding PathfindingMsg
    | Finished FinishedMsg
