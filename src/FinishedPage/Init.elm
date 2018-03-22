module FinishedPage.Init exposing (init)

import FinishedPage.Model exposing (Model)
import FinishedPage.Messages exposing (Msg(..))


init : Model -> ( Model, Cmd Msg )
init model =
    ( model, Cmd.none )
