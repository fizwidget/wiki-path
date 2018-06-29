module Page.Setup.Model exposing (SetupModel, UserInput)

import Common.Article.Model exposing (RemoteArticle)
import Common.Title.Model exposing (Title, RemoteTitlePair)


type alias SetupModel =
    { sourceTitleInput : UserInput
    , destinationTitleInput : UserInput
    , source : RemoteArticle
    , destination : RemoteArticle
    , randomTitles : RemoteTitlePair
    }


type alias UserInput =
    String
