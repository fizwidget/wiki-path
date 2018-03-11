module Main exposing (..)

import Html
import Types exposing (Msg, Model)
import View exposing (view)
import State exposing (update, subscriptions, init, initialModel)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
