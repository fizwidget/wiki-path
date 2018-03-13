module View exposing (view)

import Html exposing (Html, div, span, h1, text)
import Html.Attributes exposing (style)
import Model exposing (Model(..))
import Messages exposing (Msg(..))
import WelcomePage.View
import PathfindingPage.View


view : Model -> Html Msg
view model =
    appStyles
        [ centerChildren
            [ pageIcon
            , pageHeading
            , viewModel model
            ]
        ]


viewModel : Model -> Html Msg
viewModel model =
    case model of
        Model.WelcomePage subModel ->
            WelcomePage.View.view subModel |> Html.map Messages.WelcomePage

        Model.PathfindingPage subModel ->
            PathfindingPage.View.view subModel

        Model.FinishedPage subModel ->
            text "Not implemented (finished)"


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
