module Init exposing (init)

import Model exposing (Model(..))
import Messages exposing (Msg)
import Setup.Init


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    Setup Setup.Init.initialModel
