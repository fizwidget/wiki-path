module State exposing (update, subscriptions, init)

import Types exposing (Model(..), Msg(..))
import Setup.State
import Setup.Types
import Pathfinding.State


initialModel : Model
initialModel =
    Setup Setup.State.initialModel


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( SetupMsg innerMsg, Setup innerModel ) ->
            updateWithTransition innerMsg innerModel

        ( PathfindingMsg innerMsg, Pathfinding innerModel ) ->
            Debug.crash ("Implement me!")

        ( FinishedMsg innerMsg, Finished innerModel ) ->
            Debug.crash ("Implement me!")

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


updateWithTransition : Setup.Types.Msg -> Setup.Types.Model -> ( Model, Cmd Msg )
updateWithTransition setupMsg setupModel =
    let
        ( model, cmd, transition ) =
            Setup.State.update setupMsg setupModel
    in
        case transition of
            Just originAndDestination ->
                let
                    ( pathfindingModel, pathfindingCmd ) =
                        Pathfinding.State.init originAndDestination
                in
                    Pathfinding pathfindingModel ! [ Cmd.map PathfindingMsg pathfindingCmd, Cmd.map SetupMsg cmd ]

            Nothing ->
                ( Setup model, Cmd.map SetupMsg cmd )
