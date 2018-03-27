module Welcome.Update exposing (update)

import RemoteData
import Common.Service exposing (requestArticle)
import Model exposing (Model(Welcome))
import Messages exposing (Msg(Welcome))
import Welcome.Messages exposing (WelcomeMsg(..))
import Welcome.Model exposing (WelcomeModel)
import Pathfinding.Init


update : WelcomeMsg -> WelcomeModel -> ( Model, Cmd Msg )
update message model =
    case message of
        StartArticleTitleChange value ->
            ( Model.Welcome { model | startTitleInput = value }, Cmd.none )

        EndArticleTitleChange value ->
            ( Model.Welcome { model | endTitleInput = value }, Cmd.none )

        FetchArticlesRequest ->
            ( Model.Welcome model, getArticles model )

        FetchStartArticleResult article ->
            ( { model | startArticle = article }, Cmd.none )
                |> transitionIfDone

        FetchEndArticleResult article ->
            ( { model | endArticle = article }, Cmd.none )
                |> transitionIfDone


getArticles : WelcomeModel -> Cmd Msg
getArticles { startTitleInput, endTitleInput } =
    Cmd.map Messages.Welcome <|
        Cmd.batch
            [ requestArticle FetchStartArticleResult startTitleInput
            , requestArticle FetchEndArticleResult endTitleInput
            ]


transitionIfDone : ( WelcomeModel, Cmd Msg ) -> ( Model, Cmd Msg )
transitionIfDone ( model, cmd ) =
    RemoteData.map2 (,) model.startArticle model.endArticle
        |> RemoteData.toMaybe
        |> Maybe.map (\( start, end ) -> Pathfinding.Init.init { start = start, end = end })
        |> Maybe.withDefault ( Model.Welcome model, cmd )
