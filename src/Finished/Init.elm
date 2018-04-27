module Finished.Init exposing (init)

import Common.Title.Model exposing (Title)
import Model exposing (Model(Finished))
import Messages exposing (Msg)


init : Title -> Title -> List Title -> ( Model, Cmd Msg )
init source destination stops =
    ( Finished
        { source = source
        , destination = destination
        , stops = stops
        }
    , Cmd.none
    )
