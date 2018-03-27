module Init exposing (init)

import Model exposing (Model(WelcomePage))
import Messages exposing (Msg)
import WelcomePage.Init


init : ( Model, Cmd Msg )
init =
    WelcomePage.Init.init
