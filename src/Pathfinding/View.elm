module Pathfinding.View exposing (view)

import Css exposing (..)
import Html.Styled exposing (Html, fromUnstyled, toUnstyled, text, ol, li, h3, div)
import Html.Styled.Attributes exposing (css)
import Bootstrap.Button as Button
import Common.Article.Model exposing (Article, RemoteArticle, ArticleError)
import Common.Title.Model as Title exposing (Title)
import Common.PriorityQueue.Model as PriorityQueue exposing (PriorityQueue)
import Common.View exposing (viewLink, viewArticleError)
import Pathfinding.Messages exposing (PathfindingMsg(BackToSetup))
import Pathfinding.Model exposing (PathfindingModel, Path, Error(PathNotFound))


view : PathfindingModel -> Html PathfindingMsg
view { source, destination, priorityQueue, errors, fatalError } =
    div [ css [ displayFlex, flexDirection column, alignItems center ] ]
        [ heading source destination
        , maybeErrorView errors fatalError
        , backView
        , priorityQueueView priorityQueue
        ]


heading : Article -> Article -> Html msg
heading source destination =
    h3 [ css [ textAlign center ] ]
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
    div [ css [ margin (px 20) ] ]
        [ fromUnstyled <|
            Button.button
                [ Button.secondary, Button.onClick BackToSetup ]
                [ toUnstyled <| text "Back" ]
        ]


priorityQueueView : PriorityQueue Path -> Html msg
priorityQueueView queue =
    PriorityQueue.getHighestPriority queue
        |> Maybe.map pathView
        |> Maybe.withDefault (div [] [])


pathView : Path -> Html msg
pathView pathSoFar =
    div []
        [ (pathSoFar.next :: pathSoFar.visited)
            |> List.reverse
            |> List.map stopView
            |> ol []
        ]


stopView : Title -> Html msg
stopView title =
    li [] [ viewLink title ]
