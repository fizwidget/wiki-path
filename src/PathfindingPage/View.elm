module PathfindingPage.View exposing (view)

import Html exposing (Html, text, ol, li, h3, div)
import RemoteData
import Common.Model exposing (Article, RemoteArticle)
import PathfindingPage.Messages exposing (Msg)
import PathfindingPage.Model exposing (Model)


view : Model -> Html Msg
view { current, visited } =
    div []
        [ h3 [] [ viewCurrent current ]
        , (ol [] (List.map viewArticle visited))
        ]


viewArticle : Article -> Html msg
viewArticle article =
    li [] [ text article.title ]


viewCurrent : RemoteArticle -> Html msg
viewCurrent current =
    text <|
        case current of
            RemoteData.NotAsked ->
                "Not asked"

            RemoteData.Loading ->
                "Loading..."

            RemoteData.Success value ->
                value.title

            RemoteData.Failure error ->
                toString error
