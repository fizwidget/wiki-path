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
    transitionIfArticlesLoaded <|
        case message of
            WelcomePage.Messages.SourceArticleTitleChange value ->
                ( { model | sourceTitleInput = value }, Cmd.none )

            WelcomePage.Messages.DestinationArticleTitleChange value ->
                ( { model | destinationTitleInput = value }, Cmd.none )

            WelcomePage.Messages.FetchArticlesRequest ->
                ( model, getArticles model )

            WelcomePage.Messages.FetchSourceArticleResult article ->
                ( { model | sourceArticle = article }, Cmd.none )

            WelcomePage.Messages.FetchDestinationArticleResult article ->
                ( { model | destinationArticle = article }, Cmd.none )


transitionIfArticlesLoaded : ( WelcomePage.Model.Model, Cmd Msg ) -> ( Model.Model, Cmd Msg )
transitionIfArticlesLoaded ( model, message ) =
    RemoteData.map2 (,) model.sourceArticle model.destinationArticle
        |> RemoteData.toMaybe
        |> Maybe.map PathfindingPage.Init.init
        |> Maybe.withDefault ( Model.WelcomePage model, message )


getArticles : WelcomePage.Model.Model -> Cmd Msg
getArticles { sourceTitleInput, destinationTitleInput } =
    Cmd.map Messages.WelcomePage <|
        Cmd.batch
            [ requestArticle sourceTitleInput WelcomePage.Messages.FetchSourceArticleResult
            , requestArticle destinationTitleInput WelcomePage.Messages.FetchDestinationArticleResult
            ]
