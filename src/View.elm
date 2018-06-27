module View exposing (view)

import Css exposing (..)
import Html.Styled as Html exposing (Html, div, h1, text)
import Html.Styled.Attributes as Attributes exposing (css)
import Model exposing (Model)
import Messages exposing (Msg)
import Setup.View as Setup
import Pathfinding.View as Pathfinding
import Finished.View as Finished


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
        [ viewHeading
        , viewModel model
        ]


viewHeading : Html msg
viewHeading =
    h1
        [ css
            [ fontSize (vh 10)
            , fontWeight (int 900)
            , fontFamily serif
            , textAlign center
            , marginTop (px 50)
            , marginBottom (px 34)
            ]
        ]
        [ text "WikiPath" ]


viewModel : Model -> Html Msg
viewModel model =
    case model of
        Model.Setup subModel ->
            Setup.view subModel
                |> Html.map Messages.Setup

        Model.Pathfinding subModel ->
            Pathfinding.view subModel
                |> Html.map Messages.Pathfinding

        Model.Finished subModel ->
            Finished.view subModel
                |> Html.map Messages.Finished
