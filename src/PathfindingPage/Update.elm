module PathfindingPage.Update exposing (update)

import RemoteData
import Common.Service exposing (requestArticle)
import Common.Model exposing (Article)
import PathfindingPage.Util exposing (getCandidate)
import PathfindingPage.Messages exposing (Msg(..))
import PathfindingPage.Model exposing (Model)


-- Make separate updateModel and updateMsg functions.
-- Return an OutMsg instead of the 'transiton' thing.


update : Msg -> Model -> ( Model, Cmd Msg )
update (ArticleReceived article) model =
    Debug.log "update" <|
        case article of
            RemoteData.NotAsked ->
                ( model, Cmd.none )

            RemoteData.Loading ->
                ( model, Cmd.none )

            RemoteData.Success loadedArticle ->
                updateArticleLoaded loadedArticle model

            RemoteData.Failure error ->
                -- Handle in transition
                ( model, Cmd.none )


updateArticleLoaded : Article -> Model -> ( Model, Cmd Msg )
updateArticleLoaded article model =
    let
        hasVisited =
            (\title -> List.member title (List.map .title model.visited))

        candidateTitle =
            getCandidate article model.destination hasVisited

        _ =
            Debug.log "candidateTitle" (toString candidateTitle)

        nextCmd =
            candidateTitle
                |> Maybe.map (requestArticle ArticleReceived)
                |> Maybe.withDefault Cmd.none

        nextModel =
            { model
                | current = RemoteData.NotAsked
                , visited = article :: model.visited
            }
    in
        ( nextModel, nextCmd )
