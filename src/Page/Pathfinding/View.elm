module Page.Pathfinding.View exposing (view)

import Css exposing (..)
import Html.Styled exposing (Html, fromUnstyled, toUnstyled, text, ol, li, h3, div)
import Html.Styled.Attributes exposing (css)
import Bootstrap.Button as ButtonOptions
import Common.Button.View as Button
import Common.Article.Model exposing (Article, RemoteArticle, ArticleError)
import Common.Article.View as Article
import Common.Title.View as Title
import Common.Path.Model as Path exposing (Path)
import Common.PriorityQueue.Model as PriorityQueue exposing (PriorityQueue)
import Common.Spinner.View as Spinner
import Page.Pathfinding.Config as Config
import Page.Pathfinding.Messages exposing (PathfindingMsg(BackToSetup))
import Page.Pathfinding.Model exposing (PathfindingModel)


view : PathfindingModel -> Html PathfindingMsg
view { source, destination, paths, errors, totalRequests } =
    div [ css [ displayFlex, flexDirection column, alignItems center ] ]
        [ heading source destination
        , errorView errors
        , warningView totalRequests destination
        , backView
        , pathsView paths
        ]


heading : Article -> Article -> Html msg
heading source destination =
    h3 [ css [ textAlign center ] ]
        [ text "Finding path from "
        , Title.viewAsLink source.title
        , text " to "
        , Title.viewAsLink destination.title
        , text "..."
        ]


errorView : List ArticleError -> Html msg
errorView errors =
    div [] <| List.map Article.viewError errors


backView : Html PathfindingMsg
backView =
    div [ css [ margin (px 20) ] ]
        [ Button.view
            [ ButtonOptions.secondary, ButtonOptions.onClick BackToSetup ]
            [ text "Back" ]
        ]


warningView : Int -> Article -> Html msg
warningView totalRequests destination =
    div [ css [ textAlign center ] ]
        [ destinationContentWarning destination
        , pathCountWarning totalRequests
        ]


destinationContentWarning : Article -> Html msg
destinationContentWarning destination =
    let
        message =
            if String.contains "disambigbox" destination.content then
                "The destination article is a disambiguation page, so I probably won't be able to find a path to it \x1F916"
            else if String.length destination.content < 10000 then
                "The destination article is very short, so my pathfinding heuristic won't work well \x1F916"
            else
                ""
    in
        div [] [ text message ]


pathCountWarning : Int -> Html msg
pathCountWarning totalRequests =
    if totalRequests > Config.totalRequestsLimit // 2 then
        div [] [ text "This isn't looking good. Try a different destination maybe? 😅" ]
    else
        text ""


pathsView : PriorityQueue Path -> Html msg
pathsView paths =
    PriorityQueue.getHighestPriority paths
        |> Maybe.map pathView
        |> Maybe.withDefault (div [] [])


pathView : Path -> Html msg
pathView path =
    div [ css [ textAlign center ] ]
        [ Path.inReverseOrder path
            |> List.map Title.viewAsLink
            |> List.intersperse (text "↑")
            |> List.append [ text "↑" ]
            |> List.append [ Spinner.view { isVisible = True } ]
            |> List.map (List.singleton >> div [])
            |> div []
        ]
