module FinishedPage.Update exposing (update)

import FinishedPage.Messages exposing (Msg)
import FinishedPage.Model exposing (Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    ( model, Cmd.none )
