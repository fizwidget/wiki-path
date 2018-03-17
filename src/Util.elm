module Util exposing (tagWelcomePage, tagPathfindingPage)

import Model exposing (Model)
import Messages exposing (Msg)
import WelcomePage.Messages
import WelcomePage.Model
import PathfindingPage.Messages
import PathfindingPage.Model


tagWelcomePage : ( WelcomePage.Model.Model, Cmd WelcomePage.Messages.Msg ) -> ( Model, Cmd Msg )
tagWelcomePage ( innerModel, innerCmd ) =
    ( Model.WelcomePage innerModel, Cmd.map Messages.WelcomePage innerCmd )


tagPathfindingPage : ( PathfindingPage.Model.Model, Cmd PathfindingPage.Messages.Msg ) -> ( Model, Cmd Msg )
tagPathfindingPage ( innerModel, innerCmd ) =
    ( Model.PathfindingPage innerModel, Cmd.map Messages.PathfindingPage innerCmd )
