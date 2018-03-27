module Model exposing (Model(..))

import Welcome.Model exposing (WelcomeModel)
import Pathfinding.Model exposing (PathfindingModel)
import Finished.Model exposing (FinishedModel)


type Model
    = Welcome WelcomeModel
    | Pathfinding PathfindingModel
    | Finished FinishedModel
