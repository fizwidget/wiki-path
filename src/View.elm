module View exposing (view)

import Css exposing (..)
import Html.Styled as Html exposing (Html, fromUnstyled, toUnstyled, node, h1, text, div)
import Html.Styled.Attributes as Attributes exposing (css, rel, href)
import Bootstrap.CDN
import Model exposing (Model)
import Messages exposing (Msg)
import Setup.View
import Pathfinding.View
import Finished.View


view : Model -> Html Msg
view model =
    div
        [ css
            [ fontSize (px 24)
            , maxWidth (px 800)
            , padding (px 20)
            , marginLeft auto
            , marginRight auto
            ]
        ]
        [ externalStyles
        , enableResponsiveness
        , viewHeading
        , viewModel model
        ]


externalStyles : Html msg
externalStyles =
    div []
        [ fromUnstyled <| Bootstrap.CDN.stylesheet
        , node "link" [ rel "stylesheet", href "./Common/SpinnerStyles.css" ] []
        ]


enableResponsiveness : Html msg
enableResponsiveness =
    node "meta"
        [ Attributes.name "viewport"
        , Attributes.content "width=device-width, initial-scale=1"
        ]
        []


viewHeading : Html msg
viewHeading =
    h1
        [ css
            [ fontSize (pct 400)
            , fontWeight (int 900)
            , fontFamily serif
            , textAlign center
            , marginTop (px 50)
            , marginBottom (px 34)
            ]
        ]
        [ text "WikiLinks" ]


viewModel : Model -> Html Msg
viewModel model =
    case model of
        Model.Setup subModel ->
            Setup.View.view subModel
                |> Html.map Messages.Setup

        Model.Pathfinding subModel ->
            Pathfinding.View.view subModel
                |> Html.map Messages.Pathfinding

        Model.Finished subModel ->
            Finished.View.view subModel
                |> Html.map Messages.Finished
