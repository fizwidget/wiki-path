module WelcomePage.Init exposing (initialModel)

import RemoteData
import WelcomePage.Model exposing (Model)


initialModel : Model
initialModel =
    { sourceTitleInput = ""
    , destinationTitleInput = ""
    , sourceArticle = RemoteData.NotAsked
    , destinationArticle = RemoteData.NotAsked
    }
