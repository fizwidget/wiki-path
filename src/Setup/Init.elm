module Setup.Init exposing (init)

import RemoteData exposing (RemoteData(NotAsked))
import Model exposing (Model(Setup))
import Messages exposing (Msg)
import Setup.Model exposing (SetupModel)


init : ( Model, Cmd Msg )
init =
    ( Setup initialModel, Cmd.none )


initialModel : SetupModel
initialModel =
    { sourceTitleInput = ""
    , destinationTitleInput = ""
    , source = NotAsked
    , destination = NotAsked
    , randomizedTitles = NotAsked
    }
