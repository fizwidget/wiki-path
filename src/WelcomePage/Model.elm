module WelcomePage.Model exposing (WelcomeModel)

import Common.Model exposing (Article, RemoteArticle)


type alias WelcomeModel =
    { startTitleInput : String
    , endTitleInput : String
    , startArticle : RemoteArticle
    , endArticle : RemoteArticle
    }
