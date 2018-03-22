module WelcomePage.Update exposing (update)

import Common.Service exposing (requestArticle)
import WelcomePage.Messages exposing (Msg(..))
import WelcomePage.Model exposing (Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        StartArticleTitleChange value ->
            ( { model | startTitleInput = value }, Cmd.none )

        EndArticleTitleChange value ->
            ( { model | endTitleInput = value }, Cmd.none )

        FetchArticlesRequest ->
            ( model, getArticles model )

        FetchStartArticleResult article ->
            ( { model | startArticle = article }, Cmd.none )

        FetchEndArticleResult article ->
            ( { model | endArticle = article }, Cmd.none )


getArticles : Model -> Cmd Msg
getArticles { startTitleInput, endTitleInput } =
    Cmd.batch
        [ requestArticle FetchStartArticleResult startTitleInput
        , requestArticle FetchEndArticleResult endTitleInput
        ]
