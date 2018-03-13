module Main exposing (main)

import Html
import Model exposing (Model)
import Messages exposing (Msg)
import Update
import Subscriptions
import Init
import View


main : Program Never Model Msg
main =
    Html.program
        { init = Init.init
        , view = View.view
        , update = Update.update
        , subscriptions = Subscriptions.subscriptions
        }
