module Init exposing (init)

import Model exposing (Model)
import Messages exposing (Msg)
import Welcome.Init


init : ( Model, Cmd Msg )
init =
    Welcome.Init.init
