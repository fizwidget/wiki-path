module WelcomePage.Init exposing (init)

import RemoteData
import WelcomePage.Messages exposing (Msg)
import WelcomePage.Model exposing (Model)


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { startTitleInput = ""
    , endTitleInput = ""
    , startArticle = RemoteData.NotAsked
    , endArticle = RemoteData.NotAsked
    }
