module Setup.View.Inputs exposing (titleInputs, loadArticlesButton)

import Html exposing (Html, div, input, button, text)
import Html.Attributes exposing (value, type_, style, placeholder)
import Html.Events exposing (onInput, onClick)
import Setup.Types exposing (Msg(..))


titleInputs : Setup.Types.Model -> Html Setup.Types.Msg
titleInputs { sourceTitleInput, destinationTitleInput } =
    div []
        [ sourceArticleTitleInput sourceTitleInput
        , destinationArticleTitleInput destinationTitleInput
        ]


sourceArticleTitleInput : String -> Html Setup.Types.Msg
sourceArticleTitleInput =
    articleTitleInput "Source article" SourceArticleTitleChange


destinationArticleTitleInput : String -> Html Setup.Types.Msg
destinationArticleTitleInput =
    articleTitleInput "Destination article" DestinationArticleTitleChange


articleTitleInput : String -> (String -> Setup.Types.Msg) -> String -> Html Setup.Types.Msg
articleTitleInput placeholderText toMsg title =
    input
        [ type_ "text"
        , value title
        , placeholder placeholderText
        , onInput toMsg
        , style
            [ ( "boarder-radius", "10px" )
            , ( "background", "rgba(0, 0, 0, 0.3)" )
            , ( "color", "white" )
            , ( "font-size", "20px" )
            , ( "border", "none" )
            , ( "border-radius", "8px" )
            , ( "padding", "8px" )
            , ( "text-align", "center" )
            , ( "margin-right", "8px" )
            ]
        ]
        []


loadArticlesButton : Html Setup.Types.Msg
loadArticlesButton =
    div
        [ style [ ( "margin", "10px" ) ] ]
        [ button
            [ onClick FetchArticlesRequest
            , style
                [ ( "background", "linear-gradient(to bottom, #eae0c2 5%, #ccc2a6 100%)" )
                , ( "background-color", "#eae0c2" )
                , ( "border-radius", "15px" )
                , ( "border", "2px solid #333029" )
                , ( "cursor", "pointer" )
                , ( "color", "#505739" )
                , ( "font-size", "18px" )
                , ( "font-weight", "bold" )
                , ( "padding", "10px 20px" )
                , ( "text-decoration", "none" )
                , ( "text-shadow", "0px 1px 0px #ffffff" )
                , ( "margin-top", "10px" )
                ]
            ]
            [ text "Load articles" ]
        ]
