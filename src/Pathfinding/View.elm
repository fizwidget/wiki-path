module Pathfinding.View exposing (view)

import Html exposing (Html, text, ol, li, h3, div)
import Bootstrap.Button as Button
import Common.Model.Article exposing (Article, RemoteArticle)
import Common.Model.Title exposing (Title, value)
import Common.View exposing (viewLink)
import Pathfinding.Messages exposing (PathfindingMsg(Back))
import Pathfinding.Model exposing (PathfindingModel, Error(..))


view : PathfindingModel -> Html PathfindingMsg
view { start, end, stops, error } =
    div []
        [ heading start end
        , maybeErrorView error
        , backView
        , stopsView stops
        ]


heading : Article -> Article -> Html msg
heading start end =
    let
        startTitle =
            value start.title

        endTitle =
            value end.title
    in
        h3 [] [ text <| "Finding path from " ++ startTitle ++ " to " ++ endTitle ++ "..." ]


maybeErrorView : Maybe Error -> Html PathfindingMsg
maybeErrorView error =
    error
        |> Maybe.map errorView
        |> Maybe.withDefault (text "")


errorView : Error -> Html PathfindingMsg
errorView error =
    div []
        [ case error of
            PathNotFound title ->
                text <| "Could not find path, got stuck at: " ++ (value title)

            ArticleError articleError ->
                text ("Error fetching article: " ++ toString articleError)
        ]


backView : Html PathfindingMsg
backView =
    Button.button
        [ Button.secondary, Button.onClick Back ]
        [ text "Back" ]


stopsView : List Title -> Html msg
stopsView stops =
    ol [] <| List.map stopView stops


stopView : Title -> Html msg
stopView title =
    li [] [ viewLink title ]
