module Finished.Types exposing (..)

import Common.Types


type Msg
    = DummyMessage


type alias Model =
    Result Route


type alias Route =
    List Common.Types.Article
