module Util exposing (inWelcomePage, inPathfindingPage)

import Model exposing (Model)
import Messages exposing (Msg)
import WelcomePage.Messages
import WelcomePage.Model
import PathfindingPage.Messages
import PathfindingPage.Model


inWelcomePage : ( WelcomePage.Model.Model, Cmd WelcomePage.Messages.Msg ) -> ( Model, Cmd Msg )
inWelcomePage ( innerModel, innerCmd ) =
    ( Model.WelcomePage innerModel, Cmd.map Messages.WelcomePage innerCmd )


inPathfindingPage : ( PathfindingPage.Model.Model, Cmd PathfindingPage.Messages.Msg ) -> ( Model, Cmd Msg )
inPathfindingPage ( innerModel, innerCmd ) =
    ( Model.PathfindingPage innerModel, Cmd.map Messages.PathfindingPage innerCmd )
