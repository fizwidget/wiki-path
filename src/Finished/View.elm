module Finished.View exposing (view)

import Html exposing (Html, div, h3, h4, text)
import Bootstrap.Button as Button
import Common.Model exposing (Title(Title), Article, getTitle, value)
import Finished.Model exposing (FinishedModel)
import Finished.Messages exposing (FinishedMsg(Restart))


view : FinishedModel -> Html FinishedMsg
view model =
    div []
        [ modelView model
        , restartButton
        ]


modelView : FinishedModel -> Html msg
modelView { start, end, stops } =
    div []
        [ headingView
        , subHeadingView start end
        , stopsView stops
        ]


headingView : Html msg
headingView =
    h3 [] [ text "Success!" ]


subHeadingView : Title -> Title -> Html msg
subHeadingView startTitle endTitle =
    h4 []
        [ text <| "Path from " ++ (value startTitle) ++ " to " ++ (value endTitle) ++ "  was..." ]


stopsView : List Title -> Html msg
stopsView stops =
    stops
        |> List.reverse
        |> List.map value
        |> String.join " → "
        |> text


restartButton : Html FinishedMsg
restartButton =
    Button.button
        [ Button.secondary, Button.onClick Restart ]
        [ text "Back to start" ]