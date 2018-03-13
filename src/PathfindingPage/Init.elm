module PathfindingPage.Init exposing (init)

import Common.Model exposing (Article)
import PathfindingPage.Model
import PathfindingPage.Messages exposing (Msg)


type alias InitArgs =
    { source : Article
    , destination : Article
    }


init : InitArgs -> ( PathfindingPage.Model.Model, Cmd PathfindingPage.Messages.Msg )
init { source, destination } =
    ( { source = source, destination = destination }, Cmd.none )
