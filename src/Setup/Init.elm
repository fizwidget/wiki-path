module Setup.Init exposing (initialModel)

import RemoteData
import Setup.Model exposing (Model)


initialModel : Model
initialModel =
    { sourceTitleInput = ""
    , destinationTitleInput = ""
    , sourceArticle = RemoteData.NotAsked
    , destinationArticle = RemoteData.NotAsked
    }
