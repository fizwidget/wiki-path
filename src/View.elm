module View exposing (view)

import Html exposing (Html, h1, text)
import Html.Attributes exposing (style, rel, href)
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Model exposing (Model(..))
import Messages exposing (Msg(..))
import Setup.View
import Pathfinding.View
import Finished.View


view : Model -> Html Msg
view model =
    Grid.container [ style [ ( "max-width", "600px" ) ] ]
        [ CDN.stylesheet
        , appStyles
        , Grid.row [] [ Grid.col [] [ headingView ] ]
        , Grid.row [] [ Grid.col [] [ modelView model ] ]
        ]


appStyles : Html msg
appStyles =
    Html.node "link" [ rel "stylesheet", href "./src/Common/Styles.css" ] []


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
        [ text "WikiLinks" ]


modelView : Model -> Html Msg
modelView model =
    case model of
        Model.Setup subModel ->
            Setup.View.view subModel |> Html.map Messages.Setup

        Model.Pathfinding subModel ->
            Pathfinding.View.view subModel |> Html.map Messages.Pathfinding

        Model.Finished subModel ->
            Finished.View.view subModel |> Html.map Messages.Finished
