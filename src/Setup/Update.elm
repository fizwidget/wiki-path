module Setup.Update exposing (update)

import RemoteData exposing (RemoteData(Loading, NotAsked))
import Common.Service exposing (requestRemoteArticle)
import Common.Model.Article exposing (RemoteArticle)
import Model exposing (Model)
import Messages exposing (Msg)
import Setup.Messages exposing (SetupMsg(..))
import Setup.Model exposing (SetupModel, UserInput)
import Pathfinding.Init


update : SetupMsg -> SetupModel -> ( Model, Cmd Msg )
update message model =
    case message of
        SourceArticleTitleChange value ->
            updateSourceTitle model value

        DestinationArticleTitleChange value ->
            updateDestinationTitle model value

        FetchArticlesRequest ->
            fetchArticles model

        FetchSourceArticleResult article ->
            updateSource model article

        FetchDestinationArticleResult article ->
            updateDestination model article


updateSourceTitle : SetupModel -> UserInput -> ( Model, Cmd Msg )
updateSourceTitle model sourceTitleInput =
    ( Model.Setup
        { model
            | source = NotAsked
            , sourceTitleInput = sourceTitleInput
        }
    , Cmd.none
    )


updateDestinationTitle : SetupModel -> UserInput -> ( Model, Cmd Msg )
updateDestinationTitle model destinationTitleInput =
    ( Model.Setup
        { model
            | destination = NotAsked
            , destinationTitleInput = destinationTitleInput
        }
    , Cmd.none
    )


fetchArticles : SetupModel -> ( Model, Cmd Msg )
fetchArticles model =
    ( Model.Setup
        { model
            | source = Loading
            , destination = Loading
        }
    , getArticles model
    )


updateSource : SetupModel -> RemoteArticle -> ( Model, Cmd Msg )
updateSource model source =
    ( { model | source = source }, Cmd.none )
        |> transitionIfDone


updateDestination : SetupModel -> RemoteArticle -> ( Model, Cmd Msg )
updateDestination model destination =
    ( { model | destination = destination }, Cmd.none )
        |> transitionIfDone


getArticles : SetupModel -> Cmd Msg
getArticles { sourceTitleInput, destinationTitleInput } =
    let
        requests =
            [ requestRemoteArticle FetchSourceArticleResult sourceTitleInput
            , requestRemoteArticle FetchDestinationArticleResult destinationTitleInput
            ]
    in
        requests
            |> Cmd.batch
            |> Cmd.map Messages.Setup


transitionIfDone : ( SetupModel, Cmd Msg ) -> ( Model, Cmd Msg )
transitionIfDone ( model, cmd ) =
    RemoteData.map2 (,) model.source model.destination
        |> RemoteData.toMaybe
        |> Maybe.map (\( source, destination ) -> Pathfinding.Init.init source destination)
        |> Maybe.withDefault ( Model.Setup model, cmd )
