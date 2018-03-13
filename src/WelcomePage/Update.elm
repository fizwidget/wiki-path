module WelcomePage.Update exposing (update)

import Common.Service exposing (requestArticle)
import WelcomePage.Messages
import WelcomePage.Model
import Model exposing (Model)
import Messages exposing (Msg(..))


update : WelcomePage.Messages.Msg -> WelcomePage.Model.Model -> ( Model, Cmd Msg )
update message model =
    case message of
        WelcomePage.Messages.FetchArticlesRequest ->
            ( Model.WelcomePage model, getArticles model )

        WelcomePage.Messages.FetchSourceArticleResult article ->
            ( Model.WelcomePage { model | sourceArticle = article }, Cmd.none )

        WelcomePage.Messages.FetchDestinationArticleResult article ->
            ( Model.WelcomePage { model | destinationArticle = article }, Cmd.none )

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
