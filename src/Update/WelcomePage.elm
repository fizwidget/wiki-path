module Update.WelcomePage exposing (update)

import Model exposing (Model(WelcomePage))
import Messages exposing (Msg)
import WelcomePage.Messages
import WelcomePage.Model


update : WelcomePage.Messages.Msg -> WelcomePage.Model.Model -> ( Model, Cmd Msg )
update message model =
    ( WelcomePage model, Cmd.none )
