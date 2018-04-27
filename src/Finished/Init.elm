module Finished.Init exposing (init)

import Common.Title.Model exposing (Title)
import Model exposing (Model(Finished))
import Messages exposing (Msg)


init : List Title -> ( Model, Cmd Msg )
init stops =
    ( Finished { stops = stops }
    , Cmd.none
    )
