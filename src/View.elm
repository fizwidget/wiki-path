module View exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Types exposing (Model(..), Msg(..))
import View.Header exposing (pageIcon, pageHeading)
import Setup.View


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
        Setup model ->
            Setup.View.view model |> Html.map SetupMsg

        Pathfinding model ->
            text "Not implemented"

        Finished model ->
            text "Not implemented"
