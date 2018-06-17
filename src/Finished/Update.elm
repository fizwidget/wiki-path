module Finished.Update exposing (update)

import Setup.Init
import Model exposing (Model)
import Messages exposing (Msg)
import Common.Path.Model as Path
import Common.Title.Model as Title
import Finished.Messages exposing (FinishedMsg(BackToSetup))
import Finished.Model exposing (FinishedModel(Success, Error))


update : FinishedMsg -> FinishedModel -> ( Model, Cmd Msg )
update BackToSetup model =
    case model of
        Success pathToDestination ->
            Setup.Init.initWithInput
                (Path.beginning pathToDestination |> Title.value)
                (Path.end pathToDestination |> Title.value)

        Error _ ->
            Setup.Init.init
