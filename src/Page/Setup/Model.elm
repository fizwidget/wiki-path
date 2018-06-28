module Page.Setup.Model exposing (SetupModel, UserInput)

import Data.Article exposing (RemoteArticle)
import Data.Title exposing (Title, RemoteTitlePair)


type alias SetupModel =
    { sourceTitleInput : UserInput
    , destinationTitleInput : UserInput
    , source : RemoteArticle
    , destination : RemoteArticle
    , randomTitles : RemoteTitlePair
    }


type alias UserInput =
    String
