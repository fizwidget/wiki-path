module PathfindingPage.Transition exposing (transition)

import RemoteData
import Common.Model exposing (Title, Article)
import PathfindingPage.Model exposing (Model)


type alias Path =
    { source : Article
    , destination : Article
    , path : List Title
    }


type alias Transition =
    Result String Path


transition : Model -> Maybe Transition
transition { source, destination, current, visited } =
    case current of
        RemoteData.NotAsked ->
            Nothing

        RemoteData.Loading ->
            Nothing

        RemoteData.Success article ->
            if article.title == destination.title then
                Just
                    (Result.Ok
                        { source = source
                        , destination = destination
                        , path = visited
                        }
                    )
            else
                Nothing

        RemoteData.Failure error ->
            Just
                (Result.Err (toString error))
