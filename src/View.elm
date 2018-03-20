module View exposing (view)

import Html exposing (Html, div, span, h1, text)
import Html.Attributes exposing (style)
import Common.View exposing (centerChildren)
import Model exposing (Model(..))
import Messages exposing (Msg(..))
import WelcomePage.View
import PathfindingPage.View
import FinishedPage.View


view : Model -> Html Msg
view model =
    appStyles
        [ centerChildren
            [ iconView
            , headingView
            , modelView model
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


headingView : Html msg
headingView =
    h1
        [ style
            [ ( "font-size", "400%" )
            , ( "font-weight", "900" )
            , ( "margin-top", "0" )
            ]
        ]
        [ text "Wikipedia Game" ]


iconView : Html msg
iconView =
    span
        [ style
            [ ( "font-size", "800%" )
            , ( "line-height", "1" )
            , ( "height", "120px" )
            , ( "margin", "20px 0 10px 0" )
            ]
        ]
        [ text "📖" ]


modelView : Model -> Html Msg
modelView model =
    case model of
        Model.WelcomePage subModel ->
            WelcomePage.View.view subModel |> Html.map Messages.WelcomePage

        Model.PathfindingPage subModel ->
            PathfindingPage.View.view subModel |> Html.map Messages.PathfindingPage

        Model.FinishedPage subModel ->
            FinishedPage.View.view subModel |> Html.map Messages.FinishedPage
