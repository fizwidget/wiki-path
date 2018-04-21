module Pathfinding.View exposing (view)

import Html exposing (Html, text, ol, li, h3, div)
import Html.Attributes exposing (style)
import PairingHeap exposing (PairingHeap)
import Bootstrap.Button as Button
import Common.Model.Article exposing (Article, RemoteArticle)
import Common.Model.Title exposing (Title, value)
import Common.View exposing (viewLink)
import Pathfinding.Messages exposing (PathfindingMsg(BackToSetup))
import Pathfinding.Model exposing (PathfindingModel, Cost, Path, Error(..))


view : PathfindingModel -> Html PathfindingMsg
view { source, destination, priorityQueue, error } =
    div []
        [ heading source destination
        , maybeErrorView error
        , backView
        , priorityQueueView priorityQueue
        ]


heading : Article -> Article -> Html msg
heading source destination =
    let
        sourceTitle =
            value source.title

        destinationTitle =
            value destination.title
    in
        h3 [] [ text <| "Finding path from " ++ sourceTitle ++ " to " ++ destinationTitle ++ "..." ]


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
        [ Button.secondary, Button.onClick BackToSetup ]
        [ text "Back" ]


stopsView : Path -> Html msg
stopsView { cost, next, visited } =
    div [ style [ ( "display", "inline-block" ) ] ]
        [ text (toString -cost)
        , ol [] <| List.reverse <| List.map stopView (next :: visited)
        ]


stopView : Title -> Html msg
stopView title =
    li [] [ viewLink title ]


priorityQueueView : PairingHeap Cost Path -> Html msg
priorityQueueView queue =
    PairingHeap.toSortedList queue
        |> List.map Tuple.second
        |> List.map stopsView
        |> div []
