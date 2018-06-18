module Setup.Init exposing (init, initWithTitles)

import RemoteData exposing (RemoteData(NotAsked))
import Common.Title.Model as Title exposing (Title)
import Model exposing (Model(Setup))
import Messages exposing (Msg)
import Setup.Model exposing (SetupModel)


init : ( Model, Cmd Msg )
init =
    ( Setup (initialModel "" "")
    , Cmd.none
    )


initWithTitles : Title -> Title -> ( Model, Cmd Msg )
initWithTitles sourceTitleInput destinationTitleInput =
    ( Setup (initialModel (Title.value sourceTitleInput) (Title.value destinationTitleInput))
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
