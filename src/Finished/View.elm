module Finished.View exposing (view)

import Html exposing (Html, div, h3, h4, text, a)
import Html.Attributes exposing (href)
import Bootstrap.Button as Button
import Common.Model exposing (Title(Title), Article, getTitle, value, toLink)
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
        , stopsView start end stops
        ]


headingView : Html msg
headingView =
    h3 [] [ text "Success!" ]


subHeadingView : Title -> Title -> Html msg
subHeadingView startTitle endTitle =
    h4 []
        [ text <| "Path from " ++ (value startTitle) ++ " to " ++ (value endTitle) ++ "  was..." ]


stopsView : Title -> Title -> List Title -> Html msg
stopsView start end stops =
    stops
        |> List.map toLinkTag
        |> List.intersperse (text " → ")
        |> div []


toLinkTag : Title -> Html msg
toLinkTag title =
    a [ href (toLink title) ] [ text (value title) ]


restartButton : Html FinishedMsg
restartButton =
    Button.button
        [ Button.secondary, Button.onClick Restart ]
        [ text "Back to start" ]
