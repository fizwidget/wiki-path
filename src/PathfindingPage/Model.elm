module PathfindingPage.Model exposing (..)

import Common.Model exposing (Article)


type alias Model =
    { source : Article
    , destination : Article
    }
