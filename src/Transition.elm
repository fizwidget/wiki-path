module Transition exposing (withTransitions)

import Util exposing (liftWelcomePage, liftPathfindingPage)
import Model exposing (Model(..))
import Messages exposing (Msg)
import WelcomePage.Transition
import PathfindingPage.Init


withTransitions : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
withTransitions ( model, cmd ) =
    getTransition ( model, cmd )
        |> Maybe.map (includeCommand cmd)
        |> Maybe.withDefault ( model, cmd )


getTransition : ( Model, Cmd Msg ) -> Maybe ( Model, Cmd Msg )
getTransition ( model, cmd ) =
    case model of
        WelcomePage innerModel ->
            WelcomePage.Transition.transition innerModel
                |> Maybe.map PathfindingPage.Init.init
                |> Maybe.map liftPathfindingPage

        PathfindingPage innerModel ->
            Nothing

        FinishedPage innerModel ->
            Nothing


includeCommand : Cmd Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
includeCommand cmd ( model, otherCmd ) =
    ( model, Cmd.batch [ cmd, otherCmd ] )