module Update exposing (update)

import Model.Main exposing (Model)
import Messages exposing (Message(..))
import Commands exposing (fetchArticle)


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        FetchArticlesRequest ->
            ( model
            , fetchArticles model.sourceTitleInput model.destinationTitleInput
            )

        FetchSourceArticleResult article ->
            ( { model | sourceArticle = article }, Cmd.none )

        FetchDestinationArticleResult article ->
            ( { model | destinationArticle = article }, Cmd.none )

        SourceArticleTitleChange title ->
            ( { model | sourceTitleInput = title }, Cmd.none )

        DestinationArticleTitleChange title ->
            ( { model | destinationTitleInput = title }, Cmd.none )


fetchArticles : String -> String -> Cmd Message
fetchArticles sourceTitle destinationTitle =
    Cmd.batch
        [ fetchArticle sourceTitle FetchSourceArticleResult
        , fetchArticle destinationTitle FetchDestinationArticleResult
        ]
