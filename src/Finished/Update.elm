module Finished.Update exposing (update)

import Setup.Init
import Model exposing (Model)
import Messages exposing (Msg)
import Finished.Messages exposing (FinishedMsg(BackToSetup))
import Finished.Model exposing (FinishedModel)


update : FinishedMsg -> FinishedModel -> ( Model, Cmd Msg )
update message model =
    case message of
        BackToSetup ->
            Setup.Init.init
