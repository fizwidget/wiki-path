module PathfindingPage.Update exposing (update)

import RemoteData
import Common.Service exposing (requestArticle)
import Common.Model exposing (Title(Title), Article)
import PathfindingPage.Util exposing (getNextCandidate)
import PathfindingPage.Messages exposing (Msg(..))
import PathfindingPage.Model exposing (Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update (ArticleReceived remoteArticle) model =
    case remoteArticle of
        RemoteData.NotAsked ->
            ( { model | current = remoteArticle }, Cmd.none )

        RemoteData.Loading ->
            ( { model | current = remoteArticle }, Cmd.none )

        RemoteData.Success article ->
            let
                nextCandidate =
                    getNextCandidate article model.destination model.visited

                nextCmd =
                    nextCandidate
                        |> Maybe.map (\(Title title) -> title)
                        |> Maybe.map (requestArticle ArticleReceived)
                        |> Maybe.withDefault Cmd.none

                nextModel =
                    { model
                        | current = remoteArticle
                        , visited = article.title :: model.visited
                    }
            in
                ( nextModel, nextCmd )

        RemoteData.Failure error ->
            -- Handled in transition
            ( { model | current = remoteArticle }, Cmd.none )
