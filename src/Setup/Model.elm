module Setup.Model exposing (SetupModel)

import Common.Model.Article exposing (Article, RemoteArticle)


type alias SetupModel =
    { sourceTitleInput : String
    , destinationTitleInput : String
    , sourceArticle : RemoteArticle
    , destinationArticle : RemoteArticle
    }
