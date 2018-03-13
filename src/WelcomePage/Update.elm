module WelcomePage.Update exposing (update)

import RemoteData
import Common.Service exposing (requestArticle)
import Model
import Messages exposing (Msg(..))
import PathfindingPage.Init
import WelcomePage.Messages
import WelcomePage.Model


update : WelcomePage.Messages.Msg -> WelcomePage.Model.Model -> ( Model.Model, Cmd Msg )
update message model =
    case message of
        WelcomePage.Messages.FetchArticlesRequest ->
            ( Model.WelcomePage model, getArticles model )

        WelcomePage.Messages.FetchSourceArticleResult article ->
            ( { model | sourceArticle = article }, Cmd.none )
                |> transitionIfPossible

        WelcomePage.Messages.FetchDestinationArticleResult article ->
            ( { model | destinationArticle = article }, Cmd.none )
                |> transitionIfPossible

        WelcomePage.Messages.SourceArticleTitleChange value ->
            ( Model.WelcomePage { model | sourceTitleInput = value }, Cmd.none )

        WelcomePage.Messages.DestinationArticleTitleChange value ->
            ( Model.WelcomePage { model | destinationTitleInput = value }, Cmd.none )


getArticles : WelcomePage.Model.Model -> Cmd Msg
getArticles { sourceTitleInput, destinationTitleInput } =
    Cmd.batch
        [ requestArticle sourceTitleInput WelcomePage.Messages.FetchSourceArticleResult
        , requestArticle destinationTitleInput WelcomePage.Messages.FetchDestinationArticleResult
        ]
        |> Cmd.map Messages.WelcomePage


transitionIfPossible : ( WelcomePage.Model.Model, Cmd Msg ) -> ( Model.Model, Cmd Msg )
transitionIfPossible ( model, msg ) =
    RemoteData.map2 (,) model.sourceArticle model.destinationArticle
        |> RemoteData.toMaybe
        |> Maybe.map PathfindingPage.Init.init
        |> Maybe.withDefault ( Model.WelcomePage model, msg )
