module View exposing (view)

import Css exposing (..)
import Html.Styled as Html exposing (Html, fromUnstyled, toUnstyled, node, h1, text, div)
import Html.Styled.Attributes as Attributes exposing (css, rel, href)
import Bootstrap.CDN as CDN
import Model exposing (Model(..))
import Messages exposing (Msg(..))
import Setup.View
import Pathfinding.View
import Finished.View


view : Model -> Html Msg
view model =
    div [ css [ margin (px 20) ] ]
        [ fromUnstyled <| CDN.stylesheet
        , appStyles
        , responsiveStyles
        , headingView
        , modelView model
        ]


appStyles : Html msg
appStyles =
    node "link" [ rel "stylesheet", href "./Common/Styles.css" ] []


responsiveStyles : Html msg
responsiveStyles =
    node "meta"
        [ Attributes.name "viewport"
        , Attributes.content "width=device-width, initial-scale=1"
        ]
        []


headingView : Html msg
headingView =
    h1
        [ css
            [ fontSize (pct 400)
            , fontWeight (int 900)
            , textAlign center
            , marginTop (px 50)
            , marginBottom (px 30)
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
