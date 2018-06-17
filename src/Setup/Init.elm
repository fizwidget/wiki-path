module Setup.Init exposing (init, initWithInput)

import RemoteData exposing (RemoteData(NotAsked))
import Model exposing (Model(Setup))
import Messages exposing (Msg)
import Setup.Model exposing (SetupModel)


init : ( Model, Cmd Msg )
init =
    ( Setup (initialModel "" "")
    , Cmd.none
    )


initWithInput : String -> String -> ( Model, Cmd Msg )
initWithInput sourceTitleInput destinationTitleInput =
    ( Setup (initialModel sourceTitleInput destinationTitleInput)
    , Cmd.none
    )


initialModel : String -> String -> SetupModel
initialModel sourceTitleInput destinationTitleInput =
    { sourceTitleInput = sourceTitleInput
    , destinationTitleInput = destinationTitleInput
    , source = NotAsked
    , destination = NotAsked
    , randomTitles = NotAsked
    }
