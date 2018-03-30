module Pathfinding.View exposing (view)

import Html exposing (Html, text, ol, li, h3, div)
import Bootstrap.Button as Button
import Common.Model exposing (Title(Title), Article, RemoteArticle, getTitle)
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
            getTitle start

        endTitle =
            getTitle end
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
            PathNotFound ->
                text "Could not find path :("

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
stopView (Title title) =
    li [] [ text title ]
