module Welcome.Model exposing (WelcomeModel)

import Common.Model.Article exposing (Article, RemoteArticle)


type alias WelcomeModel =
    { startTitleInput : String
    , endTitleInput : String
    , startArticle : RemoteArticle
    , endArticle : RemoteArticle
    }
