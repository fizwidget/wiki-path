module Update exposing (update)

import Model exposing (Model)
import Messages exposing (Msg)
import Setup.Update as Setup
import Pathfinding.Update as Pathfinding
import Finished.Update as Finished


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( Messages.Setup innerMsg, Model.Setup innerModel ) ->
            Setup.update innerMsg innerModel

        ( Messages.Pathfinding innerMsg, Model.Pathfinding innerModel ) ->
            Pathfinding.update innerMsg innerModel

        ( Messages.Finished innerMsg, Model.Finished innerModel ) ->
            Finished.update innerMsg innerModel

        ( _, _ ) ->
            -- Ignore messages that didn't originate from the current page
            ( model, Cmd.none )
