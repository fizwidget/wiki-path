module Welcome.Model exposing (WelcomeModel)

import Common.Model.Article exposing (Article, RemoteArticle)


type alias WelcomeModel =
    { sourceTitleInput : String
    , destinationTitleInput : String
    , sourceArticle : RemoteArticle
    , destinationArticle : RemoteArticle
    }
