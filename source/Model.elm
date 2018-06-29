module Model exposing (Model(..))

import Page.Setup.Model exposing (SetupModel)
import Page.Pathfinding.Model exposing (PathfindingModel)
import Page.Finished.Model exposing (FinishedModel)


type Model
    = Setup SetupModel
    | Pathfinding PathfindingModel
    | Finished FinishedModel
