module Update exposing (update)

import Model exposing (Model)
import Messages exposing (Message(FetchArticleRequest, FetchArticleResult, ArticleTitleChange))
import Commands exposing (fetchArticle)


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        FetchArticleRequest ->
            ( model, fetchArticle model.title )

        FetchArticleResult response ->
            ( { model | article = response }, Cmd.none )

        ArticleTitleChange title ->
            ( { model | title = title }, Cmd.none )
