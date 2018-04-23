module Setup.Model exposing (SetupModel, UserInput)

import Common.Model.Article exposing (Article, RemoteArticle)


type alias SetupModel =
    { sourceTitleInput : UserInput
    , destinationTitleInput : UserInput
    , source : RemoteArticle
    , destination : RemoteArticle
    }


type alias UserInput =
    String
