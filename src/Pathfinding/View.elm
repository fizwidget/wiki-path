module Pathfinding.View exposing (view)

import Html exposing (Html, text, ol, li, h3, div)
import Html.Attributes exposing (style)
import Bootstrap.Button as Button
import Common.Model.Article exposing (Article, RemoteArticle, ArticleError)
import Common.Model.Title exposing (Title, value)
import Common.View exposing (viewLink, viewArticleError)
import Pathfinding.Messages exposing (PathfindingMsg(BackToSetup))
import Pathfinding.Model exposing (PathfindingModel, Cost, Path, Error(..))
import Pathfinding.Model.PriorityQueue as PriorityQueue exposing (PriorityQueue)


view : PathfindingModel -> Html PathfindingMsg
view { source, destination, priorityQueue, errors, fatalError } =
    div []
        [ heading source destination
        , maybeErrorView errors fatalError
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


maybeErrorView : List ArticleError -> Maybe Error -> Html PathfindingMsg
maybeErrorView errors fatalError =
    div []
        [ Maybe.map fatalErrorView fatalError
            |> Maybe.withDefault (text "")
        , errorsView errors
        ]


fatalErrorView : Error -> Html PathfindingMsg
fatalErrorView PathNotFound =
    text "Path not found :("


errorsView : List ArticleError -> Html msg
errorsView errors =
    div [] (List.map viewArticleError errors)


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


priorityQueueView : PriorityQueue Cost Path -> Html msg
priorityQueueView queue =
    PriorityQueue.toSortedList queue
        |> List.map stopsView
        |> div []
