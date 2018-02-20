module Main exposing (..)

import Html exposing (program)
import Model exposing (Model, initialModel)
import View exposing (view)
import Messages exposing (Message)
import Update exposing (update)
import Subscriptions exposing (subscriptions)


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Message )
init =
    ( initialModel, Cmd.none )
