module Model exposing (Model(..))

import WelcomePage.Model exposing (WelcomeModel)
import PathfindingPage.Model exposing (PathfindingModel)
import FinishedPage.Model exposing (FinishedModel)


type Model
    = WelcomePage WelcomeModel
    | PathfindingPage PathfindingModel
    | FinishedPage FinishedModel
