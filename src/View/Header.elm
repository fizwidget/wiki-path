module View.Header exposing (pageIcon, pageHeading)

import Html exposing (Html, text, span, h1)
import Html.Attributes exposing (style)


pageIcon : Html msg
pageIcon =
    span
        [ style
            [ ( "font-size", "800%" )
            , ( "line-height", "1" )
            , ( "height", "120px" )
            , ( "margin", "20px 0 10px 0" )
            ]
        ]
        [ text "📖" ]


pageHeading : Html msg
pageHeading =
    h1
        [ style
            [ ( "font-size", "400%" )
            , ( "font-weight", "900" )
            , ( "margin-top", "0" )
            ]
        ]
        [ text "Wikipedia Game" ]
