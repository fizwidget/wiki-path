module Messages exposing (..)

import WelcomePage.Messages
import PathfindingPage.Messages
import FinishedPage.Messages


type Msg
    = WelcomePageMsg WelcomePage.Messages.Msg
    | PathfindingPageMsg PathfindingPage.Messages.Msg
    | FinishedPage FinishedPage.Messages.Msg
