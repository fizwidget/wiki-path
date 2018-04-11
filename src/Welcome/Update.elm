module Welcome.Update exposing (update)

import RemoteData exposing (RemoteData(Loading, NotAsked))
import Common.Service exposing (requestArticle)
import Model exposing (Model)
import Messages exposing (Msg)
import Welcome.Messages exposing (WelcomeMsg(..))
import Welcome.Model exposing (WelcomeModel)
import Pathfinding.Init


update : WelcomeMsg -> WelcomeModel -> ( Model, Cmd Msg )
update message model =
    case message of
        SourceArticleTitleChange value ->
            ( Model.Welcome { model | sourceTitleInput = value, sourceArticle = NotAsked }, Cmd.none )

        DestinationArticleTitleChange value ->
            ( Model.Welcome { model | destinationTitleInput = value, destinationArticle = NotAsked }, Cmd.none )

        FetchArticlesRequest ->
            ( Model.Welcome { model | sourceArticle = Loading, destinationArticle = Loading }
            , Cmd.map Messages.Welcome (getArticles model)
            )

        FetchSourceArticleResult article ->
            ( { model | sourceArticle = article }, Cmd.none )
                |> transitionIfDone

        FetchDestinationArticleResult article ->
            ( { model | destinationArticle = article }, Cmd.none )
                |> transitionIfDone


getArticles : WelcomeModel -> Cmd WelcomeMsg
getArticles { sourceTitleInput, destinationTitleInput } =
    Cmd.batch
        [ requestArticle FetchSourceArticleResult sourceTitleInput
        , requestArticle FetchDestinationArticleResult destinationTitleInput
        ]


transitionIfDone : ( WelcomeModel, Cmd Msg ) -> ( Model, Cmd Msg )
transitionIfDone ( model, cmd ) =
    RemoteData.map2 (,) model.sourceArticle model.destinationArticle
        |> RemoteData.toMaybe
        |> Maybe.map (\( source, destination ) -> Pathfinding.Init.init source destination)
        |> Maybe.withDefault ( Model.Welcome model, cmd )
