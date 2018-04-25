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
            setSourceTitle model value

        DestinationArticleTitleChange value ->
            setDestinationTitle model value

        FetchArticlesRequest ->
            loadArticles model

        FetchSourceArticleResult article ->
            setSourceArticle model article

        FetchDestinationArticleResult article ->
            setDestinationArticle model article


setSourceTitle : SetupModel -> UserInput -> ( Model, Cmd Msg )
setSourceTitle model sourceTitleInput =
    ( Model.Setup
        { model
            | source = NotAsked
            , sourceTitleInput = sourceTitleInput
        }
    , Cmd.none
    )


setDestinationTitle : SetupModel -> UserInput -> ( Model, Cmd Msg )
setDestinationTitle model destinationTitleInput =
    ( Model.Setup
        { model
            | destination = NotAsked
            , destinationTitleInput = destinationTitleInput
        }
    , Cmd.none
    )


loadArticles : SetupModel -> ( Model, Cmd Msg )
loadArticles model =
    ( Model.Setup
        { model
            | source = Loading
            , destination = Loading
        }
    , requestArticles model
    )


requestArticles : SetupModel -> Cmd Msg
requestArticles { sourceTitleInput, destinationTitleInput } =
    let
        requests =
            [ requestRemoteArticle FetchSourceArticleResult sourceTitleInput
            , requestRemoteArticle FetchDestinationArticleResult destinationTitleInput
            ]
    in
        requests
            |> Cmd.batch
            |> Cmd.map Messages.Setup


setSourceArticle : SetupModel -> RemoteArticle -> ( Model, Cmd Msg )
setSourceArticle model source =
    ( { model | source = source }, Cmd.none )
        |> transitionIfDone


setDestinationArticle : SetupModel -> RemoteArticle -> ( Model, Cmd Msg )
setDestinationArticle model destination =
    ( { model | destination = destination }, Cmd.none )
        |> transitionIfDone


transitionIfDone : ( SetupModel, Cmd Msg ) -> ( Model, Cmd Msg )
transitionIfDone ( model, cmd ) =
    RemoteData.map2 (,) model.source model.destination
        |> RemoteData.toMaybe
        |> Maybe.map (\( source, destination ) -> Pathfinding.Init.init source destination)
        |> Maybe.withDefault ( Model.Setup model, cmd )
