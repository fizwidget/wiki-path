module WelcomePage.Update exposing (update)

import RemoteData
import Common.Service exposing (requestArticle)
import Model exposing (Model(WelcomePage))
import Messages exposing (Msg(WelcomePage))
import WelcomePage.Messages exposing (WelcomeMsg(..))
import WelcomePage.Model exposing (WelcomeModel)
import PathfindingPage.Init


update : WelcomeMsg -> WelcomeModel -> ( Model, Cmd Msg )
update message model =
    case message of
        StartArticleTitleChange value ->
            ( Model.WelcomePage { model | startTitleInput = value }, Cmd.none )

        EndArticleTitleChange value ->
            ( Model.WelcomePage { model | endTitleInput = value }, Cmd.none )

        FetchArticlesRequest ->
            ( Model.WelcomePage model, getArticles model )

        FetchStartArticleResult article ->
            ( { model | startArticle = article }, Cmd.none )
                |> transitionIfDone

        FetchEndArticleResult article ->
            ( { model | endArticle = article }, Cmd.none )
                |> transitionIfDone


getArticles : WelcomeModel -> Cmd Msg
getArticles { startTitleInput, endTitleInput } =
    Cmd.map Messages.WelcomePage <|
        Cmd.batch
            [ requestArticle FetchStartArticleResult startTitleInput
            , requestArticle FetchEndArticleResult endTitleInput
            ]


transitionIfDone : ( WelcomeModel, Cmd Msg ) -> ( Model, Cmd Msg )
transitionIfDone ( model, cmd ) =
    RemoteData.map2 (,) model.startArticle model.endArticle
        |> RemoteData.toMaybe
        |> Maybe.map (\( start, end ) -> PathfindingPage.Init.init { start = start, end = end })
        |> Maybe.withDefault ( Model.WelcomePage model, cmd )
