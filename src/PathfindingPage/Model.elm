module PathfindingPage.Model exposing (..)

import Common.Model exposing (Article, RemoteArticle)


type alias Model =
    { source : Article
    , destination : Article
    , current : RemoteArticle
    , visited : List Article
    }
