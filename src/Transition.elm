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
    performTransition message ( model, cmd )
        |> Maybe.withDefault ( model, cmd )


performTransition : Msg -> ( Model, Cmd Msg ) -> Maybe ( Model, Cmd Msg )
performTransition message ( model, cmd ) =
    Maybe.map (include cmd) <|
        case ( message, model ) of
            ( Messages.WelcomePage innerMsg, Model.WelcomePage innerModel ) ->
                WelcomePage.Transition.transition innerModel
                    |> Maybe.map (PathfindingPage.Init.init >> inPathfindingPage)

            ( Messages.PathfindingPage innerMsg, Model.PathfindingPage innerModel ) ->
                PathfindingPage.Transition.transition innerMsg innerModel
                    |> Maybe.map (FinishedPage.Init.init >> inFinishedPage)

            ( Messages.FinishedPage innerMsg, Model.FinishedPage innerModel ) ->
                FinishedPage.Transition.transition innerMsg
                    |> Maybe.map (always <| inWelcomePage WelcomePage.Init.init)

            ( _, _ ) ->
                -- Ignore messages that didn't originate from the current page
                Nothing


include : Cmd Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
include cmd ( model, otherCmd ) =
    ( model, Cmd.batch [ cmd, otherCmd ] )
