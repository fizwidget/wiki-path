module PathfindingPage.View exposing (view)

import Html exposing (Html, text)
import Messages exposing (Msg)
import PathfindingPage.Model
import PathfindingPage.View.Content exposing (articlesContent)


view : PathfindingPage.Model.Model -> Html Msg
view { source, destination } =
    articlesContent source destination
