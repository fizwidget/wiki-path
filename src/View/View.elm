module View exposing (view)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Model exposing (Model)
import Messages exposing (Msg)
import View.Content exposing (articlesContent)
import View.Header exposing (pageIcon, pageHeading)
import View.Inputs exposing (titleInputs, loadArticlesButton)


view : Model -> Html Msg
view model =
    appStyles
        [ centerChildren
            [ pageIcon
            , pageHeading
            , titleInputs model
            , loadArticlesButton
            , articlesContent model.sourceArticle model.destinationArticle
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
