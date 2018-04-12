module Setup.Update exposing (update)

import RemoteData exposing (RemoteData(Loading, NotAsked))
import Common.Service exposing (requestArticle)
import Model exposing (Model)
import Messages exposing (Msg)
import Setup.Messages exposing (SetupMsg(..))
import Setup.Model exposing (SetupModel)
import Pathfinding.Init


update : SetupMsg -> SetupModel -> ( Model, Cmd Msg )
update message model =
    case message of
        SourceArticleTitleChange value ->
            ( Model.Setup { model | sourceTitleInput = value, sourceArticle = NotAsked }, Cmd.none )

        DestinationArticleTitleChange value ->
            ( Model.Setup { model | destinationTitleInput = value, destinationArticle = NotAsked }, Cmd.none )

        FetchArticlesRequest ->
            ( Model.Setup { model | sourceArticle = Loading, destinationArticle = Loading }
            , Cmd.map Messages.Setup (getArticles model)
            )

        FetchSourceArticleResult article ->
            ( { model | sourceArticle = article }, Cmd.none )
                |> transitionIfDone

        FetchDestinationArticleResult article ->
            ( { model | destinationArticle = article }, Cmd.none )
                |> transitionIfDone


getArticles : SetupModel -> Cmd SetupMsg
getArticles { sourceTitleInput, destinationTitleInput } =
    Cmd.batch
        [ requestArticle FetchSourceArticleResult sourceTitleInput
        , requestArticle FetchDestinationArticleResult destinationTitleInput
        ]


transitionIfDone : ( SetupModel, Cmd Msg ) -> ( Model, Cmd Msg )
transitionIfDone ( model, cmd ) =
    let
        articles =
            RemoteData.map2 (,) model.sourceArticle model.destinationArticle
                |> RemoteData.toMaybe
    in
        case articles of
            Just ( source, destination ) ->
                Pathfinding.Init.init source destination

            Nothing ->
                ( Model.Setup model, cmd )
