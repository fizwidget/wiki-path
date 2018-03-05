module Update exposing (update)

import Model exposing (Model)
import Messages exposing (Msg(..))
import Commands exposing (getArticles)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        FetchArticlesRequest ->
            model
                ! [ getArticles model.sourceTitleInput model.destinationTitleInput ]

        FetchSourceArticleResult article ->
            { model | sourceArticle = article }
                ! [ Cmd.none ]

        FetchDestinationArticleResult article ->
            { model | destinationArticle = article }
                ! [ Cmd.none ]

        SourceArticleTitleChange value ->
            { model | sourceTitleInput = value }
                ! [ Cmd.none ]

        DestinationArticleTitleChange value ->
            { model | destinationTitleInput = value }
                ! [ Cmd.none ]
