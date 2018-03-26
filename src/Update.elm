module Update exposing (update)

import Model exposing (Model(..))
import Messages exposing (Msg)
import Util exposing (inWelcomePage, inPathfindingPage, inFinishedPage)
import WelcomePage.Messages
import WelcomePage.Model
import WelcomePage.Update
import PathfindingPage.Messages
import PathfindingPage.Model
import PathfindingPage.Update
import PathfindingPage.Init
import FinishedPage.Messages
import FinishedPage.Model
import FinishedPage.Update
import FinishedPage.Init


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( Messages.WelcomePage innerMsg, Model.WelcomePage innerModel ) ->
            welcomePageUpdate innerMsg innerModel

        ( Messages.PathfindingPage innerMsg, Model.PathfindingPage innerModel ) ->
            pathfindingPageUpdate innerMsg innerModel

        ( Messages.FinishedPage innerMsg, Model.FinishedPage innerModel ) ->
            finishedPageUpdate innerMsg innerModel

        ( _, _ ) ->
            -- Ignore messages that didn't originate from the current page
            ( model, Cmd.none )


welcomePageUpdate : WelcomePage.Messages.Msg -> WelcomePage.Model.Model -> ( Model, Cmd Msg )
welcomePageUpdate message model =
    let
        ( nextModel, nextCmd, transition ) =
            inWelcomePage <| WelcomePage.Update.update message model
    in
        transition
            |> Maybe.map PathfindingPage.Init.init
            |> Maybe.map inPathfindingPage
            |> Maybe.map (include nextCmd)
            |> Maybe.withDefault ( nextModel, nextCmd )


pathfindingPageUpdate : PathfindingPage.Messages.Msg -> PathfindingPage.Model.Model -> ( Model, Cmd Msg )
pathfindingPageUpdate message model =
    let
        ( nextModel, nextCmd, transition ) =
            inPathfindingPage <| PathfindingPage.Update.update message model
    in
        transition
            |> Maybe.map FinishedPage.Init.init
            |> Maybe.map inFinishedPage
            |> Maybe.withDefault ( nextModel, nextCmd )


finishedPageUpdate : FinishedPage.Messages.Msg -> FinishedPage.Model.Model -> ( Model, Cmd Msg )
finishedPageUpdate message model =
    inFinishedPage <| FinishedPage.Update.update message model


include : Cmd msg -> ( Model, Cmd msg ) -> ( Model, Cmd msg )
include cmd ( model, otherCmd ) =
    ( model, Cmd.batch [ cmd, otherCmd ] )
