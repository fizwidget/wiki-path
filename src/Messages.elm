module Messages exposing (..)

import WelcomePage.Messages
import PathfindingPage.Messages
import FinishedPage.Messages


type Msg
    = WelcomePage WelcomePage.Messages.Msg
    | PathfindingPage PathfindingPage.Messages.Msg
    | FinishedPage FinishedPage.Messages.Msg
