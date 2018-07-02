module Main exposing (main)

import Html
import Html.Styled exposing (toUnstyled)
import Page.Setup as Setup
import Model exposing (Model)
import Messages exposing (Msg)
import Update
import View


main : Program Never Model Msg
main =
    Html.program
        { init = Setup.init
        , view = View.view >> toUnstyled
        , update = Update.update
        , subscriptions = \_ -> Sub.none
        }
