module View exposing (view)

import Html exposing (Html, h1, text)
import Html.Attributes exposing (style)
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Model exposing (Model(..))
import Messages exposing (Msg(..))
import WelcomePage.View
import PathfindingPage.View
import FinishedPage.View


view : Model -> Html Msg
view model =
    Grid.container [ style [ ( "max-width", "600px" ) ] ]
        [ CDN.stylesheet
        , Grid.row [] [ Grid.col [] [ headingView ] ]
        , Grid.row [] [ Grid.col [] [ modelView model ] ]
        ]


headingView : Html msg
headingView =
    h1
        [ style
            [ ( "font-size", "400%" )
            , ( "font-weight", "900" )
            , ( "text-align", "center" )
            , ( "margin-top", "50px" )
            , ( "margin-bottom", "30px" )
            ]
        ]
        [ text "Wikipedia Game" ]


modelView : Model -> Html Msg
modelView model =
    case model of
        Model.WelcomePage subModel ->
            WelcomePage.View.view subModel |> Html.map Messages.WelcomePage

        Model.PathfindingPage subModel ->
            PathfindingPage.View.view subModel |> Html.map Messages.PathfindingPage

        Model.FinishedPage subModel ->
            FinishedPage.View.view subModel |> Html.map Messages.FinishedPage
