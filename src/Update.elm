module Update exposing (update)

import Model exposing (Model(WelcomePage, PathfindingPage, Finished))
import Messages exposing (Msg(WelcomePageMsg, PathfindingPageMsg, FinishedPage))
import WelcomePage.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( WelcomePageMsg innerMsg, WelcomePage innerModel ) ->
            WelcomePage.Update.update innerMsg innerModel

        ( PathfindingPageMsg innerMsg, PathfindingPage innerModel ) ->
            Debug.crash ("Implement me!")

        ( FinishedPage innerMsg, Finished innerModel ) ->
            Debug.crash ("Implement me!")

        ( _, _ ) ->
            -- Ignore messages from other pages
            ( model, Cmd.none )
