module Util exposing (liftWelcomePage, liftPathfindingPage)

import Model exposing (Model)
import Messages exposing (Msg)
import WelcomePage.Messages
import WelcomePage.Model
import PathfindingPage.Messages
import PathfindingPage.Model


liftWelcomePage : ( WelcomePage.Model.Model, Cmd WelcomePage.Messages.Msg ) -> ( Model, Cmd Msg )
liftWelcomePage ( innerModel, innerCmd ) =
    ( Model.WelcomePage innerModel, Cmd.map Messages.WelcomePage innerCmd )


liftPathfindingPage : ( PathfindingPage.Model.Model, Cmd PathfindingPage.Messages.Msg ) -> ( Model, Cmd Msg )
liftPathfindingPage ( innerModel, innerCmd ) =
    ( Model.PathfindingPage innerModel, Cmd.map Messages.PathfindingPage innerCmd )
