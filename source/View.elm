module View exposing (view)

import Css exposing (..)
import Html.Styled as Html exposing (Html, div, h1, text)
import Html.Styled.Attributes as Attributes exposing (css)
import Page.Setup.View as Setup
import Page.Pathfinding.View as Pathfinding
import Page.Finished.View as Finished
import Model exposing (Model)
import Messages exposing (Msg)

view : Model -> Html Msg
view model
    pageFrame << viewModel


pageFrame : Html Msg -> Html Msg
pageFrame pageContent =
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
        , pageContent
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
        Model.Setup innerModel ->
            Setup.view innerModel
                |> Html.map Messages.Setup

        Model.Pathfinding innerModel ->
            Pathfinding.view innerModel
                |> Html.map Messages.Pathfinding

        Model.Finished innerModel ->
            Finished.view innerModel
                |> Html.map Messages.Finished
