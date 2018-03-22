module PathfindingPage.Init exposing (init)

import RemoteData
import Common.Model exposing (Title(Title), Article)
import Common.Service exposing (requestArticle)
import PathfindingPage.Model exposing (Model)
import PathfindingPage.Messages exposing (Msg(..))
import PathfindingPage.Util exposing (getNextCandidate)


type alias InitArgs =
    { source : Article
    , destination : Article
    }


init : InitArgs -> ( Model, Cmd Msg )
init { source, destination } =
    let
        initialModel =
            { source = source
            , destination = destination
            , current = RemoteData.Success source
            , visited = [ source.title ]
            }

        initialCmd =
            getNextCandidate source destination initialModel.visited
                |> Maybe.map (\(Title title) -> requestArticle ArticleReceived title)
                |> Maybe.withDefault Cmd.none
    in
        ( initialModel, initialCmd )
