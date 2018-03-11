module State exposing (update, subscriptions, init, initialModel)

import Types exposing (Model(..), Msg(..))
import Setup.State
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
            let
                ( model, cmd, transition ) =
                    Setup.State.update innerMsg innerModel
            in
                case transition of
                    Just originAndDestination ->
                        let
                            ( pathfindingModel, pathfindingCmd ) =
                                Pathfinding.State.init originAndDestination
                        in
                            ( Pathfinding pathfindingModel, Cmd.batch [ Cmd.map PathfindingMsg pathfindingCmd, Cmd.map SetupMsg cmd ] )

                    Nothing ->
                        ( Setup model, Cmd.map SetupMsg cmd )

        ( PathfindingMsg innerMsg, Pathfinding innerModel ) ->
            Debug.crash ("Implement me!")

        ( FinishedMsg innerMsg, Finished innerModel ) ->
            Debug.crash ("Implement me!")

        _ ->
            Debug.crash ("Shit")


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
