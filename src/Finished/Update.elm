module Finished.Update exposing (update)

import Setup.Init
import Model exposing (Model)
import Messages exposing (Msg)
import Common.Path.Model as Path
import Finished.Messages exposing (FinishedMsg(BackToSetup))
import Finished.Model exposing (FinishedModel(Success, Error))


update : FinishedMsg -> FinishedModel -> ( Model, Cmd Msg )
update BackToSetup model =
    case model of
        Success pathToDestination ->
            Setup.Init.initWithTitles
                (Path.beginning pathToDestination)
                (Path.end pathToDestination)

        Error _ ->
            Setup.Init.init
