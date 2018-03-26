module Update.PathfindingPage exposing (update)

import Model exposing (Model)
import Messages exposing (Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    ( model, Cmd.none )
