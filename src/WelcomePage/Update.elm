module WelcomePage.Update exposing (update)

import RemoteData
import Common.Service exposing (requestArticle)
import Common.Model exposing (Article)
import WelcomePage.Messages exposing (Msg(..))
import WelcomePage.Model exposing (Model)


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg )
update message model =
    case message of
        SourceArticleTitleChange value ->
            ( { model | sourceTitleInput = value }, Cmd.none, NoOp )

        DestinationArticleTitleChange value ->
            ( { model | destinationTitleInput = value }, Cmd.none, NoOp )

        FetchArticlesRequest ->
            ( model, getArticles model, NoOp )

        FetchSourceArticleResult article ->
            let
                newModel =
                    { model | sourceArticle = article }

                outMsg =
                    withOutput newModel
            in
                ( newModel, Cmd.none, outMsg )

        FetchDestinationArticleResult article ->
            let
                newModel =
                    { model | destinationArticle = article }

                outMsg =
                    withOutput newModel
            in
                ( newModel, Cmd.none, outMsg )


type alias SourceAndDestination =
    { source : Article
    , destination : Article
    }


type OutMsg
    = Complete SourceAndDestination
    | NoOp


withOutput : Model -> OutMsg
withOutput { sourceArticle, destinationArticle } =
    RemoteData.map2 SourceAndDestination sourceArticle destinationArticle
        |> RemoteData.map Complete
        |> RemoteData.toMaybe
        |> Maybe.withDefault NoOp


getArticles : Model -> Cmd Msg
getArticles { sourceTitleInput, destinationTitleInput } =
    Cmd.batch
        [ requestArticle FetchSourceArticleResult sourceTitleInput
        , requestArticle FetchDestinationArticleResult destinationTitleInput
        ]
