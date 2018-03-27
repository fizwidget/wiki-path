module Finished.Init exposing (init)

import Common.Model exposing (Title)
import Model exposing (Model(Finished))
import Messages exposing (Msg)


init : Title -> Title -> List Title -> ( Model, Cmd Msg )
init start end stops =
    ( Finished { start = start, end = end, stops = stops }
    , Cmd.none
    )
