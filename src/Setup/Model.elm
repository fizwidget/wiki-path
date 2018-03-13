module Setup.Model exposing (Model)

import Common.Model exposing (Article, RemoteArticle)


type alias Model =
    { sourceTitleInput : String
    , destinationTitleInput : String
    , sourceArticle : RemoteArticle
    , destinationArticle : RemoteArticle
    }
