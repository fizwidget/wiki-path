module Main exposing (..)

import Html exposing (program)
import Model.Main exposing (Model, initialModel)
import View.Page exposing (view)
import Messages exposing (Message)
import Update exposing (update)
import Subscriptions exposing (subscriptions)


main : Program Never Model Message
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
