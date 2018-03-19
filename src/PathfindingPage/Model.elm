module PathfindingPage.Model exposing (Model)

import Common.Model exposing (Title, Article, RemoteArticle)


type alias Model =
    { source : Article
    , destination : Article
    , current : RemoteArticle
    , visited : List Title
    }
