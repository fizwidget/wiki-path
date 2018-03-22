module PathfindingPage.Model exposing (Model)

import Common.Model exposing (Title, Article, RemoteArticle)


type alias Model =
    { start : Article
    , end : Article
    , stops : List Title
    }
