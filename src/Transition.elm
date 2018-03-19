module Transition exposing (withTransitions)

import Util exposing (inWelcomePage, inPathfindingPage)
import Model exposing (Model(..))
import Messages exposing (Msg)
import WelcomePage.Transition
import PathfindingPage.Transition
import PathfindingPage.Init


withTransitions : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
withTransitions ( model, cmd ) =
    getTransition ( model, cmd )
        |> Maybe.withDefault ( model, cmd )


getTransition : ( Model, Cmd Msg ) -> Maybe ( Model, Cmd Msg )
getTransition ( model, cmd ) =
    case model of
        WelcomePage innerModel ->
            WelcomePage.Transition.transition innerModel
                |> Maybe.map (PathfindingPage.Init.init >> inPathfindingPage)
                |> Maybe.map (batchCmd cmd)

        -- TODO: Implement properly
        PathfindingPage innerModel ->
            PathfindingPage.Transition.transition innerModel
                |> always Nothing

        FinishedPage innerModel ->
            Nothing


batchCmd : Cmd Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
batchCmd cmd ( model, otherCmd ) =
    ( model, Cmd.batch [ cmd, otherCmd ] )
