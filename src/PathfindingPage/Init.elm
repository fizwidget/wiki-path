module PathfindingPage.Init exposing (init)

import Common.Model exposing (Article)
import Model exposing (Model)
import Messages exposing (Msg)


init : ( Article, Article ) -> ( Model, Cmd Msg )
init ( source, destination ) =
    ( Model.PathfindingPage { source = source, destination = destination }, Cmd.none )
