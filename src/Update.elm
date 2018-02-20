module Update exposing (update)

import Model exposing (Model)
import Messages exposing (Message(FetchArticleRequest, FetchArticleResult, ArticleUrlChange))
import Commands exposing (fetchArticle)
import Debug exposing (log)


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    let
        _ =
            log "message" (toString message)
    in
        case message of
            FetchArticleRequest ->
                ( model, fetchArticle model.articleUrl )

            FetchArticleResult response ->
                ( { model | articleContent = response }, Cmd.none )

            ArticleUrlChange url ->
                ( { model | articleUrl = url }, Cmd.none )
