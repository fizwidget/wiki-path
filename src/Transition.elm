module Transition exposing (withTransition)

import Util exposing (inWelcomePage, inPathfindingPage, inFinishedPage)
import Model exposing (Model(..))
import Messages exposing (Msg)
import WelcomePage.Transition
import PathfindingPage.Transition
import FinishedPage.Transition
import WelcomePage.Init
import PathfindingPage.Init
import FinishedPage.Init


withTransition : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
withTransition message ( model, cmd ) =
    performTransition message model
        |> Maybe.map (batch cmd)
        |> Maybe.withDefault ( model, cmd )


performTransition : Msg -> Model -> Maybe ( Model, Cmd Msg )
performTransition message model =
    case ( message, model ) of
        ( Messages.WelcomePage innerMsg, Model.WelcomePage innerModel ) ->
            WelcomePage.Transition.transition innerModel
                |> Maybe.map PathfindingPage.Init.init
                |> Maybe.map inPathfindingPage

        ( Messages.PathfindingPage innerMsg, Model.PathfindingPage innerModel ) ->
            PathfindingPage.Transition.transition innerMsg innerModel
                |> Maybe.map FinishedPage.Init.init
                |> Maybe.map inFinishedPage

        ( Messages.FinishedPage innerMsg, Model.FinishedPage innerModel ) ->
            FinishedPage.Transition.transition innerMsg
                |> Maybe.map (always WelcomePage.Init.init)
                |> Maybe.map inWelcomePage

        ( _, _ ) ->
            -- Ignore messages that didn't originate from the current page
            Nothing


batch : Cmd Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
batch cmd ( model, otherCmd ) =
    ( model, Cmd.batch [ cmd, otherCmd ] )
