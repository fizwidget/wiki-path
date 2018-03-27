module FinishedPage.Update exposing (update)

import WelcomePage.Init
import Model exposing (Model)
import Messages exposing (Msg(..))
import FinishedPage.Messages exposing (FinishedMsg(Restart))
import FinishedPage.Model exposing (FinishedModel)


update : FinishedMsg -> FinishedModel -> ( Model, Cmd Msg )
update message model =
    case message of
        Restart ->
            WelcomePage.Init.init
