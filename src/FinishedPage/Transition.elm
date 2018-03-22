module FinishedPage.Transition exposing (transition)

import FinishedPage.Messages exposing (Msg(Restart))


type Transition
    = Done


transition : Msg -> Maybe Transition
transition message =
    case message of
        Restart ->
            Just Done
