module Welcome.Init exposing (init)

import RemoteData exposing (RemoteData(NotAsked))
import Model exposing (Model(Welcome))
import Messages exposing (Msg)
import Welcome.Model exposing (WelcomeModel)


init : ( Model, Cmd Msg )
init =
    ( Welcome initialModel, Cmd.none )


initialModel : WelcomeModel
initialModel =
    { sourceTitleInput = ""
    , destinationTitleInput = ""
    , sourceArticle = NotAsked
    , destinationArticle = NotAsked
    }
