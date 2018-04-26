module Main exposing (main)

import Html
import Html.Styled exposing (toUnstyled)
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
        , view = View.view >> toUnstyled
        , update = Update.update
        , subscriptions = Subscriptions.subscriptions
        }
