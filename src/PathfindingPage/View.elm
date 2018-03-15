module PathfindingPage.View exposing (view)

import Html exposing (Html, text)
import PathfindingPage.Messages exposing (Msg)
import PathfindingPage.Model exposing (Model)
import PathfindingPage.View.Content exposing (articlesContent)


view : Model -> Html Msg
view { source, destination } =
    articlesContent source destination
