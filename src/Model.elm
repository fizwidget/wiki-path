module Model exposing (..)

import Setup.Model
import Pathfinding.Model
import Finished.Model


type Model
    = Setup Setup.Model.Model
    | Pathfinding Pathfinding.Model.Model
    | Finished Finished.Model.Model
