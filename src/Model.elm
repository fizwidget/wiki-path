module Model exposing (Model(..))

import Setup.Model exposing (SetupModel)
import Pathfinding.Model exposing (PathfindingModel)
import Finished.Model exposing (FinishedModel)


type Model
    = Setup SetupModel
    | Pathfinding PathfindingModel
    | Finished FinishedModel
