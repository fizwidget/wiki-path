module Init exposing (init)

import Model exposing (Model(Welcome))
import Messages exposing (Msg)
import Welcome.Init


init : ( Model, Cmd Msg )
init =
    Welcome.Init.init
