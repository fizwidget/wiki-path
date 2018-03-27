module WelcomePage.Init exposing (init)

import RemoteData
import Model exposing (Model(WelcomePage))
import Messages exposing (Msg)
import WelcomePage.Model exposing (WelcomeModel)


init : ( Model, Cmd Msg )
init =
    ( WelcomePage initialModel, Cmd.none )


initialModel : WelcomeModel
initialModel =
    { startTitleInput = ""
    , endTitleInput = ""
    , startArticle = RemoteData.NotAsked
    , endArticle = RemoteData.NotAsked
    }
