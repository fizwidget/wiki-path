module PathfindingPage.Init exposing (init)

import RemoteData
import Common.Model exposing (Article)
import PathfindingPage.Model exposing (Model)
import PathfindingPage.Messages exposing (Msg(..))
import PathfindingPage.Util exposing (getCandidate)
import Common.Service exposing (requestArticle)


type alias InitArgs =
    { source : Article
    , destination : Article
    }


init : InitArgs -> ( Model, Cmd Msg )
init { source, destination } =
    ( { source = source
      , destination = destination
      , current = RemoteData.NotAsked
      , visited = [ source ]
      }
    , initialCmd source destination
    )


initialCmd : Article -> Article -> Cmd Msg
initialCmd source destination =
    let
        candidate =
            getCandidate source destination (always False)

        _ =
            Debug.log "candidate" candidate
    in
        candidate
            |> Maybe.map (requestArticle ArticleReceived)
            |> Maybe.withDefault Cmd.none
