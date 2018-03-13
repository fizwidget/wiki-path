module Init exposing (init)

import Model exposing (Model(WelcomePage))
import Messages exposing (Msg)
import WelcomePage.Init


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    WelcomePage WelcomePage.Init.initialModel
