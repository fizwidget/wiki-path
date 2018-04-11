module Finished.View exposing (view)

import Html exposing (Html, div, h3, h4, text, a)
import Bootstrap.Button as Button
import Common.Model.Title exposing (Title, value)
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
    h3 [] [ text "Success!" ]


subHeadingView : Title -> Title -> Html msg
subHeadingView sourceTitle destinationTitle =
    h4 []
        [ text <| "Path from " ++ (value sourceTitle) ++ " to " ++ (value destinationTitle) ++ "  was..." ]


stopsView : Title -> Title -> List Title -> Html msg
stopsView source destination stops =
    stops
        |> List.map viewLink
        |> List.intersperse (text " → ")
        |> div []


restartButton : Html FinishedMsg
restartButton =
    Button.button
        [ Button.secondary, Button.onClick BackToSetup ]
        [ text "Back" ]
