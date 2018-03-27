module Welcome.Init exposing (init)

import RemoteData
import Model exposing (Model(Welcome))
import Messages exposing (Msg)
import Welcome.Model exposing (WelcomeModel)


init : ( Model, Cmd Msg )
init =
    ( Welcome initialModel, Cmd.none )


initialModel : WelcomeModel
initialModel =
    { startTitleInput = ""
    , endTitleInput = ""
    , startArticle = RemoteData.NotAsked
    , endArticle = RemoteData.NotAsked
    }
