module Pathfinding.View exposing (view)

import Html exposing (Html, text, ol, li, h3, div)
import Html.Attributes exposing (style)
import Bootstrap.Button as Button
import Common.Model.Article exposing (Article, RemoteArticle, ArticleError)
import Common.Model.Title as Title exposing (Title)
import Common.Model.PriorityQueue as PriorityQueue exposing (PriorityQueue)
import Common.View exposing (viewLink, viewArticleError)
import Pathfinding.Messages exposing (PathfindingMsg(BackToSetup))
import Pathfinding.Model exposing (PathfindingModel, Path, Error(..))


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
    h3 []
        [ text <|
            "Finding path from "
                ++ Title.value source.title
                ++ " to "
                ++ Title.value destination.title
                ++ "..."
        ]


maybeErrorView : List ArticleError -> Maybe Error -> Html msg
maybeErrorView errors fatalError =
    div []
        [ fatalErrorView fatalError
        , errorsView errors
        ]


fatalErrorView : Maybe Error -> Html msg
fatalErrorView error =
    error
        |> Maybe.map (\PathNotFound -> text "Path not found :(")
        |> Maybe.withDefault (text "")


errorsView : List ArticleError -> Html msg
errorsView errors =
    div [] <| List.map viewArticleError errors


backView : Html PathfindingMsg
backView =
    Button.button
        [ Button.secondary, Button.onClick BackToSetup ]
        [ text "Back" ]


priorityQueueView : PriorityQueue Path -> Html msg
priorityQueueView queue =
    PriorityQueue.toSortedList queue
        |> List.map pathView
        |> div []


pathView : Path -> Html msg
pathView pathSoFar =
    div [ style [ ( "display", "inline-block" ) ] ]
        [ text (toString pathSoFar.priority)
        , (pathSoFar.next :: pathSoFar.visited)
            |> List.reverse
            |> List.map stopView
            |> ol []
        ]


stopView : Title -> Html msg
stopView title =
    li [] [ viewLink title ]
