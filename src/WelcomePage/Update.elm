module WelcomePage.Update exposing (update)

import Common.Service exposing (requestArticle)
import WelcomePage.Messages exposing (Msg(..))
import WelcomePage.Model exposing (Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        SourceArticleTitleChange value ->
            ( { model | sourceTitleInput = value }, Cmd.none )

        DestinationArticleTitleChange value ->
            ( { model | destinationTitleInput = value }, Cmd.none )

        FetchArticlesRequest ->
            ( model, getArticles model )

        FetchSourceArticleResult article ->
            ( { model | sourceArticle = article }, Cmd.none )

        FetchDestinationArticleResult article ->
            ( { model | destinationArticle = article }, Cmd.none )


getArticles : Model -> Cmd Msg
getArticles { sourceTitleInput, destinationTitleInput } =
    Cmd.batch
        [ requestArticle FetchSourceArticleResult sourceTitleInput
        , requestArticle FetchDestinationArticleResult destinationTitleInput
        ]
