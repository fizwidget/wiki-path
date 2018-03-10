module View exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Model exposing (Model(..))
import Messages exposing (Msg)
import View.Header exposing (pageIcon, pageHeading)
import ChoosingEndpoints.View exposing (choosingEndpointsView)


view : Model -> Html Msg
view model =
    appStyles
        [ centerChildren
            [ pageIcon
            , pageHeading
            , renderContent model
            ]
        ]


appStyles : List (Html msg) -> Html msg
appStyles children =
    div
        [ style
            [ ( "font-family", "Helvetica" )
            , ( "color", "#f9d094" )
            , ( "background", "#2e2a24" )
            , ( "min-height", "100vh" )
            , ( "padding", "20px" )
            ]
        ]
        children


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


renderContent : Model -> Html Msg
renderContent model =
    case model of
        ChoosingEndpoints model ->
            choosingEndpointsView model

        FindingRoute model ->
            text "Not implemented"

        FinishedRouting model ->
            text "Not implemented"
