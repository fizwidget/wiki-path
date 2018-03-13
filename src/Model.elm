module Model exposing (Model(..))

import WelcomePage.Model
import PathfindingPage.Model
import FinishedPage.Model


type Model
    = WelcomePage WelcomePage.Model.Model
    | PathfindingPage PathfindingPage.Model.Model
    | FinishedPage FinishedPage.Model.Model
