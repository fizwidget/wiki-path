module Model exposing (Model(..))

import Page.Setup as Setup
import Page.Pathfinding.Model exposing (PathfindingModel)
import Page.Finished.Model exposing (FinishedModel)


type Model
    = Setup Setup.Model
    | Pathfinding PathfindingModel
    | Finished FinishedModel
