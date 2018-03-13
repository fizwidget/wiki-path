module PathfindingPage.Update exposing (update)

import Model
import Messages exposing (Msg(..))
import PathfindingPage.Messages
import PathfindingPage.Model


update : PathfindingPage.Messages.Msg -> PathfindingPage.Model.Model -> ( Model.Model, Cmd Msg )
update message model =
    case message of
        PathfindingPage.Messages.DummyMsg ->
            ( Model.PathfindingPage model, Cmd.none )
