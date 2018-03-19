module PathfindingPage.View exposing (view)

import Html exposing (Html, text, ol, li, h3, div)
import RemoteData
import Common.Model exposing (Title(Title), Article, RemoteArticle, getTitle)
import PathfindingPage.Messages exposing (Msg)
import PathfindingPage.Model exposing (Model)


view : Model -> Html Msg
view { source, destination, current, visited } =
    div []
        [ heading source destination
        , currentArticle current
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


currentArticle : RemoteArticle -> Html msg
currentArticle current =
    text <|
        case current of
            RemoteData.NotAsked ->
                "Article has not been requested"

            RemoteData.Loading ->
                "Loading next article..."

            RemoteData.Success article ->
                getTitle article

            RemoteData.Failure error ->
                "Error fetching article: " ++ (toString error)
