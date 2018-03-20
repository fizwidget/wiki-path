module Common.View exposing (centerChildren)

import Html exposing (Html, div, span, h1, text)
import Html.Attributes exposing (style)


centerChildren : List (Html msg) -> Html msg
centerChildren children =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-direction", "column" )
            , ( "align-items", "center" )
            ]
        ]
        children
