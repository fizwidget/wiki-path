module WelcomePage.Update exposing (update)

import Common.Service exposing (requestArticle)
import WelcomePage.Messages
import WelcomePage.Model


update : WelcomePage.Messages.Msg -> WelcomePage.Model.Model -> ( WelcomePage.Model.Model, Cmd WelcomePage.Messages.Msg )
update message model =
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


getArticles : WelcomePage.Model.Model -> Cmd WelcomePage.Messages.Msg
getArticles { sourceTitleInput, destinationTitleInput } =
    Cmd.batch
        [ requestArticle sourceTitleInput WelcomePage.Messages.FetchSourceArticleResult
        , requestArticle destinationTitleInput WelcomePage.Messages.FetchDestinationArticleResult
        ]
