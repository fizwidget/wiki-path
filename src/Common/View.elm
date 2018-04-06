module Common.View exposing (viewLink, viewSpinner)

import Html exposing (Html, div, text, a)
import Html.Attributes exposing (href, class, style)
import Common.Model.Title exposing (Title, value)


viewLink : Title -> Html msg
viewLink title =
    a [ href (toUrl title) ] [ text (value title) ]


toUrl : Title -> String
toUrl title =
    "https://en.wikipedia.org/wiki/" ++ (value title)


viewSpinner : Html msg
viewSpinner =
    div
        [ class "lds-ellipsis" ]
        [ div [] []
        , div [] []
        , div [] []
        , div [] []
        ]


outerSpinnerStyles : Styles
outerSpinnerStyles =
    [ ( "display", "inline-block" )
    , ( "position", "relative" )
    , ( "width", "64px" )
    , ( "height", "64px" )
    ]


innerSpinnerStyles : Styles
innerSpinnerStyles =
    [ ( "position", "absolute" )
    , ( "top", "27px" )
    , ( "width", "11px" )
    , ( "height", "11px" )
    , ( "border-radius", "50%" )
    , ( "background", "#cef" )
    , ( "animation-timing-function", "cubic-bezier(0, 1, 1, 0)" )
    ]


type alias Styles =
    List ( String, String )
