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
            requestArticles model

        FetchSourceArticleResult article ->
            updateSourceArticleResult model article

        FetchDestinationArticleResult article ->
            updateDestinationArticleResult model article


updateSourceTitle : SetupModel -> UserInput -> ( Model, Cmd Msg )
updateSourceTitle model sourceTitle =
    ( Model.Setup
        { model
            | sourceTitleInput = sourceTitle
            , source = NotAsked
        }
    , Cmd.none
    )


updateDestinationTitle : SetupModel -> UserInput -> ( Model, Cmd Msg )
updateDestinationTitle model destinationTitle =
    ( Model.Setup
        { model
            | destinationTitleInput = destinationTitle
            , destination = NotAsked
        }
    , Cmd.none
    )


requestArticles : SetupModel -> ( Model, Cmd Msg )
requestArticles model =
    ( Model.Setup
        { model
            | source = Loading
            , destination = Loading
        }
    , getArticles model
    )


updateSourceArticleResult : SetupModel -> RemoteArticle -> ( Model, Cmd Msg )
updateSourceArticleResult model source =
    ( { model | source = source }, Cmd.none )
        |> transitionIfDone


updateDestinationArticleResult : SetupModel -> RemoteArticle -> ( Model, Cmd Msg )
updateDestinationArticleResult model destination =
    ( { model | destination = destination }, Cmd.none )
        |> transitionIfDone


getArticles : SetupModel -> Cmd Msg
getArticles { sourceTitleInput, destinationTitleInput } =
    let
        articleRequests =
            [ requestRemoteArticle FetchSourceArticleResult sourceTitleInput
            , requestRemoteArticle FetchDestinationArticleResult destinationTitleInput
            ]
    in
        articleRequests
            |> Cmd.batch
            |> Cmd.map Messages.Setup


transitionIfDone : ( SetupModel, Cmd Msg ) -> ( Model, Cmd Msg )
transitionIfDone ( model, cmd ) =
    RemoteData.map2 (,) model.source model.destination
        |> RemoteData.toMaybe
        |> Maybe.map (\( source, destination ) -> Pathfinding.Init.init source destination)
        |> Maybe.withDefault ( Model.Setup model, cmd )
