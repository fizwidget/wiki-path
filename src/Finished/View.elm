module Finished.View exposing (view)

import Html exposing (Html, div, h2, h4, text, a)
import Html.Attributes exposing (style)
import Bootstrap.Button as Button
import Common.Title.Model as Title exposing (Title)
import Common.View exposing (viewLink)
import Finished.Model exposing (FinishedModel)
import Finished.Messages exposing (FinishedMsg(BackToSetup))


view : FinishedModel -> Html FinishedMsg
view model =
    div []
        [ modelView model
        , restartButton
        ]


modelView : FinishedModel -> Html msg
modelView { source, destination, stops } =
    div []
        [ headingView
        , subHeadingView source destination
        , stopsView source destination stops
        ]


headingView : Html msg
headingView =
    h2 [] [ text "Success!" ]


subHeadingView : Title -> Title -> Html msg
subHeadingView sourceTitle destinationTitle =
    h4 []
        [ text <| "Path from " ++ (Title.value sourceTitle) ++ " to " ++ (Title.value destinationTitle) ++ "  was..." ]


stopsView : Title -> Title -> List Title -> Html msg
stopsView source destination stops =
    stops
        |> List.map viewLink
        |> List.intersperse (text " → ")
        |> div []


restartButton : Html FinishedMsg
restartButton =
    div [ style [ ( "margin", "20px" ) ] ]
        [ Button.button
            [ Button.secondary, Button.onClick BackToSetup ]
            [ text "Back" ]
        ]
