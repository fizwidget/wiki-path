module Update exposing (update)

import Model exposing (Model(..))
import Messages exposing (Msg(..))
import Setup.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( SetupMsg innerMsg, Setup innerModel ) ->
            Setup.Update.update innerMsg innerModel

        ( PathfindingMsg innerMsg, Pathfinding innerModel ) ->
            Debug.crash ("Implement me!")

        ( FinishedMsg innerMsg, Finished innerModel ) ->
            Debug.crash ("Implement me!")

        ( _, _ ) ->
            -- Ignore messages from other pages
            ( model, Cmd.none )
