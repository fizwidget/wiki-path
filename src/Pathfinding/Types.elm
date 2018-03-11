module Pathfinding.Types exposing (..)

import Common.Types exposing (Article)


type Msg
    = DummyMessage


type alias Model =
    { source : Article
    , destination : Article
    }
