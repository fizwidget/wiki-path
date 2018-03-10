module ChoosingEndpoints.Update exposing (choosingEndpointsUpdate)

import Messages exposing (Msg(..))
import ChoosingEndpoints.Model exposing (ChoosingEndpointsModel)
import Model exposing (Model(ChoosingEndpoints))
import ChoosingEndpoints.Commands exposing (getArticles)


choosingEndpointsUpdate : Msg -> ChoosingEndpointsModel -> ( Model, Cmd Msg )
choosingEndpointsUpdate message model =
    case message of
        FetchArticlesRequest ->
            ChoosingEndpoints model
                ! [ getArticles model.sourceTitleInput model.destinationTitleInput ]

        FetchSourceArticleResult article ->
            ChoosingEndpoints { model | sourceArticle = article }
                ! [ Cmd.none ]

        FetchDestinationArticleResult article ->
            ChoosingEndpoints { model | destinationArticle = article }
                ! [ Cmd.none ]

        SourceArticleTitleChange value ->
            ChoosingEndpoints { model | sourceTitleInput = value }
                ! [ Cmd.none ]

        DestinationArticleTitleChange value ->
            ChoosingEndpoints { model | destinationTitleInput = value }
                ! [ Cmd.none ]
