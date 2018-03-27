module FinishedPage.Init exposing (init)

import Common.Model exposing (Title)
import Model exposing (Model(FinishedPage))
import Messages exposing (Msg)


init : Title -> Title -> List Title -> ( Model, Cmd Msg )
init start end stops =
    ( FinishedPage { start = start, end = end, stops = stops }
    , Cmd.none
    )
