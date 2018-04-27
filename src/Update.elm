module Update exposing (update)

import Model exposing (Model)
import Messages exposing (Msg(ToSetup))
import Setup.Update
import Finished.Init
import Setup.Init
import Pathfinding.Init
import Pathfinding.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ToSetup ->
            Setup.Init.init

        _ ->
            case ( message, model ) of
                ( Messages.Setup innerMsg, Model.Setup innerModel ) ->
                    let
                        ( updatedModel, outputCmd, maybeArticles ) =
                            Setup.Update.update innerMsg innerModel
                    in
                        maybeArticles
                            |> Maybe.map (\{ source, destination } -> Pathfinding.Init.init source destination)
                            |> Maybe.withDefault ( updatedModel, outputCmd )

                ( Messages.Pathfinding innerMsg, Model.Pathfinding innerModel ) ->
                    let
                        ( updatedModel, outputCmd, maybePath ) =
                            Pathfinding.Update.update innerMsg innerModel
                    in
                        maybePath
                            |> Maybe.map Finished.Init.init
                            |> Maybe.withDefault ( updatedModel, outputCmd )

                ( _, _ ) ->
                    -- Ignore messages that didn't originate from the current page
                    ( model, Cmd.none )
