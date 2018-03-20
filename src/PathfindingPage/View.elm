module PathfindingPage.View exposing (view)

import Html exposing (Html, text, ol, li, h3, div)
import Common.Model exposing (Title(Title), Article, RemoteArticle, getTitle)
import PathfindingPage.Messages exposing (Msg)
import PathfindingPage.Model exposing (Model)


view : Model -> Html Msg
view { source, destination, current, visited } =
    div []
        [ heading source destination
        , visitedArticles visited
        ]


heading : Article -> Article -> Html msg
heading source destination =
    let
        sourceTitle =
            getTitle source

        destinationTitle =
            getTitle destination
    in
        h3 [] [ text <| "Finding path from " ++ sourceTitle ++ " to " ++ destinationTitle ++ "..." ]


visitedArticles : List Title -> Html msg
visitedArticles visited =
    ol [] <| List.map visitedArticle visited


visitedArticle : Title -> Html msg
visitedArticle (Title title) =
    li [] [ text title ]
