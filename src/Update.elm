module Update exposing (update)

import Util exposing (tagWelcomePage, tagPathfindingPage)
import Model exposing (Model)
import Messages exposing (Msg)
import Transition exposing (withTransitions)
import WelcomePage.Update
import PathfindingPage.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( Messages.WelcomePage innerMsg, Model.WelcomePage innerModel ) ->
            WelcomePage.Update.update innerMsg innerModel
                |> handleWelcomePageOutput
                |> tagWelcomePage

        ( Messages.PathfindingPage innerMsg, Model.PathfindingPage innerModel ) ->
            tagPathfindingPage <| PathfindingPage.Update.update innerMsg innerModel

        ( Messages.FinishedPage innerMsg, Model.FinishedPage innerModel ) ->
            Debug.crash ("Implement me!")

        ( _, _ ) ->
            -- Ignore messages that didn't originate from the current page
            ( model, Cmd.none )
