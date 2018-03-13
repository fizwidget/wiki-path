module PathfindingPage.Update exposing (update)

import PathfindingPage.Messages
import PathfindingPage.Model


update : PathfindingPage.Messages.Msg -> PathfindingPage.Model.Model -> ( PathfindingPage.Model.Model, Cmd PathfindingPage.Messages.Msg )
update message model =
    case message of
        PathfindingPage.Messages.DummyMsg ->
            ( model, Cmd.none )
