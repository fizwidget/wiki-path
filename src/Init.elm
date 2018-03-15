module Init exposing (init)

import Util exposing (inWelcomePage)
import Model exposing (Model(WelcomePage))
import Messages exposing (Msg)
import WelcomePage.Init


init : ( Model, Cmd Msg )
init =
    inWelcomePage WelcomePage.Init.init
