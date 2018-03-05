module Main exposing (..)

import Html exposing (program)
import Model exposing (Model, initialModel)
import View exposing (view)
import Messages exposing (Msg)
import Update exposing (update)
import Subscriptions exposing (subscriptions)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )
