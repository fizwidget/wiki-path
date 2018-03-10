module Update exposing (update)

import Model exposing (Model(..))
import Messages exposing (Msg(..))
import ChoosingEndpoints.Update exposing (choosingEndpointsUpdate)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case model of
        ChoosingEndpoints innerModel ->
            choosingEndpointsUpdate message innerModel

        FindingRoute innerModel ->
            Debug.crash ("Implement me!")

        FinishedRouting innerModel ->
            Debug.crash ("Implement me!")
