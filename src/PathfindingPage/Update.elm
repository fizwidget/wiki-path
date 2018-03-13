module PathfindingPage.Update exposing (update)

import PathfindingPage.Messages exposing (Msg(..))
import PathfindingPage.Model exposing (Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        DummyMsg ->
            ( model, Cmd.none )
