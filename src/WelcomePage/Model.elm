module WelcomePage.Model exposing (Model)

import Common.Model exposing (Article, RemoteArticle)


type alias Model =
    { startTitleInput : String
    , endTitleInput : String
    , startArticle : RemoteArticle
    , endArticle : RemoteArticle
    }
