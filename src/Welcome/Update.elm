module Welcome.Update exposing (update)

import RemoteData
import Common.Service exposing (requestArticle)
import Model exposing (Model)
import Messages exposing (Msg)
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
            ( Model.Welcome { model | startArticle = RemoteData.Loading, endArticle = RemoteData.Loading }
            , Cmd.map Messages.Welcome (getArticles model)
            )

        FetchStartArticleResult article ->
            ( { model | startArticle = article }, Cmd.none )
                |> transitionIfDone

        FetchEndArticleResult article ->
            ( { model | endArticle = article }, Cmd.none )
                |> transitionIfDone


getArticles : WelcomeModel -> Cmd WelcomeMsg
getArticles { startTitleInput, endTitleInput } =
    Cmd.batch
        [ requestArticle FetchStartArticleResult startTitleInput
        , requestArticle FetchEndArticleResult endTitleInput
        ]


transitionIfDone : ( WelcomeModel, Cmd Msg ) -> ( Model, Cmd Msg )
transitionIfDone ( model, cmd ) =
    RemoteData.map2 (,) model.startArticle model.endArticle
        |> RemoteData.toMaybe
        |> Maybe.map (\( start, end ) -> Pathfinding.Init.init start end)
        |> Maybe.withDefault ( Model.Welcome model, cmd )
