module Update exposing (update)

import Model exposing (Model)
import Messages exposing (Msg)
import Welcome.Update
import Pathfinding.Update
import Finished.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( Messages.Welcome innerMsg, Model.Welcome innerModel ) ->
            Welcome.Update.update innerMsg innerModel

        ( Messages.Pathfinding innerMsg, Model.Pathfinding innerModel ) ->
            Pathfinding.Update.update innerMsg innerModel

        ( Messages.Finished innerMsg, Model.Finished innerModel ) ->
            Finished.Update.update innerMsg innerModel

        ( _, _ ) ->
            -- Ignore messages that didn't originate from the current page
            ( model, Cmd.none )
