module Page.Setup.Init exposing (init, initWithTitles)

import RemoteData exposing (RemoteData(NotAsked))
import Common.Title.Model as Title exposing (Title)
import Page.Setup.Model exposing (SetupModel)
import Model exposing (Model(Setup))
import Messages exposing (Msg)


init : ( Model, Cmd Msg )
init =
    ( Setup <| initialModel "" "", Cmd.none )


initWithTitles : Title -> Title -> ( Model, Cmd Msg )
initWithTitles source destination =
    ( Setup <| initialModel (Title.value source) (Title.value destination)
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
