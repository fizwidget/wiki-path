module Init exposing (init)

import Util exposing (tagWelcomePage)
import Model exposing (Model(WelcomePage))
import Messages exposing (Msg)
import WelcomePage.Init


init : ( Model, Cmd Msg )
init =
    tagWelcomePage WelcomePage.Init.init
