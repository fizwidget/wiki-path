module FinishedPage.Model exposing (..)

import Common.Model exposing (Article)


type Msg
    = DummyMessage


type alias Model =
    Result String Route


type alias Route =
    List Article
