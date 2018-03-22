module PathfindingPage.View exposing (view)

import Html exposing (Html, text, ol, li, h3, div)
import Common.Model exposing (Title(Title), Article, RemoteArticle, getTitle)
import PathfindingPage.Messages exposing (Msg)
import PathfindingPage.Model exposing (Model)


view : Model -> Html Msg
view { start, end, stops } =
    div []
        [ heading start end
        , stopsArticles stops
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


stopsArticles : List Title -> Html msg
stopsArticles stops =
    ol [] <| List.map stopsArticle stops


stopsArticle : Title -> Html msg
stopsArticle (Title title) =
    li [] [ text title ]
