module Init exposing (init)

import Util exposing (liftWelcomePage)
import Model exposing (Model(WelcomePage))
import Messages exposing (Msg)
import WelcomePage.Init


init : ( Model, Cmd Msg )
init =
    liftWelcomePage WelcomePage.Init.init
