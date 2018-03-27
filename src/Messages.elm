module Messages exposing (..)

import WelcomePage.Messages exposing (WelcomeMsg)
import PathfindingPage.Messages exposing (PathfindingMsg)
import FinishedPage.Messages exposing (FinishedMsg)


type Msg
    = WelcomePage WelcomeMsg
    | PathfindingPage PathfindingMsg
    | FinishedPage FinishedMsg
