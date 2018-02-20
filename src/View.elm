module View exposing (view)

import Html exposing (Html, text)
import Model exposing (Model)
import Messages exposing (Message)


view : Model -> Html Message
view model =
    text "Hello"
