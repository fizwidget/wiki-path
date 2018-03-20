module Transition exposing (withTransitions)

import Util exposing (inWelcomePage, inPathfindingPage, inFinishedPage)
import Model exposing (Model(..))
import Messages exposing (Msg)
import WelcomePage.Transition
import PathfindingPage.Transition
import PathfindingPage.Init
import FinishedPage.Init


withTransitions : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
withTransitions ( model, cmd ) =
    getTransition ( model, cmd )
        |> Maybe.withDefault ( model, cmd )


getTransition : ( Model, Cmd Msg ) -> Maybe ( Model, Cmd Msg )
getTransition ( model, cmd ) =
    Maybe.map (batchCmd cmd) <|
        case model of
            WelcomePage innerModel ->
                WelcomePage.Transition.transition innerModel
                    |> Maybe.map (PathfindingPage.Init.init >> inPathfindingPage)

            PathfindingPage innerModel ->
                PathfindingPage.Transition.transition innerModel
                    |> Maybe.map (FinishedPage.Init.init >> inFinishedPage)

            FinishedPage innerModel ->
                Nothing


batchCmd : Cmd Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
batchCmd cmd ( model, otherCmd ) =
    ( model, Cmd.batch [ cmd, otherCmd ] )
