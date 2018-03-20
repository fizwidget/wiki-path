module FinishedPage.Init exposing (init)

import FinishedPage.Model exposing (Model)
import FinishedPage.Messages exposing (Msg(..))


type alias InitArgs =
    Model


init : InitArgs -> ( Model, Cmd Msg )
init initArgs =
    ( initArgs, Cmd.none )
