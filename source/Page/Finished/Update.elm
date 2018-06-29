module Page.Finished.Update exposing (update)

import Model exposing (Model)
import Messages exposing (Msg)
import Common.Path.Model as Path
import Page.Setup.Init as Setup
import Page.Finished.Messages exposing (FinishedMsg(BackToSetup))
import Page.Finished.Model exposing (FinishedModel(Success, Error))


update : FinishedMsg -> FinishedModel -> ( Model, Cmd Msg )
update BackToSetup model =
    case model of
        Success pathToDestination ->
            Setup.initWithTitles
                (Path.beginning pathToDestination)
                (Path.end pathToDestination)

        Error { source, destination } ->
            Setup.initWithTitles source.title destination.title
