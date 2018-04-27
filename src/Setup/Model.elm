module Setup.Model exposing (SetupModel, UserInput)

import Common.Article.Model exposing (RemoteArticle)


type alias SetupModel =
    { sourceTitleInput : UserInput
    , destinationTitleInput : UserInput
    , source : RemoteArticle
    , destination : RemoteArticle
    }


type alias UserInput =
    String
