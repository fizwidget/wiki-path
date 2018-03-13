module Setup.Update exposing (update)

import Common.Service exposing (requestArticle)
import Setup.Messages
import Setup.Model
import Model exposing (Model)
import Messages exposing (Msg(..))


update : Setup.Messages.Msg -> Setup.Model.Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Setup.Messages.FetchArticlesRequest ->
            ( Model.Setup model, getArticles model )

        Setup.Messages.FetchSourceArticleResult article ->
            ( Model.Setup { model | sourceArticle = article }, Cmd.none )

        Setup.Messages.FetchDestinationArticleResult article ->
            ( Model.Setup { model | destinationArticle = article }, Cmd.none )

        Setup.Messages.SourceArticleTitleChange value ->
            ( Model.Setup { model | sourceTitleInput = value }, Cmd.none )

        Setup.Messages.DestinationArticleTitleChange value ->
            ( Model.Setup { model | destinationTitleInput = value }, Cmd.none )


getArticles : Setup.Model.Model -> Cmd Msg
getArticles { sourceTitleInput, destinationTitleInput } =
    Cmd.batch
        [ requestArticle sourceTitleInput Setup.Messages.FetchSourceArticleResult
        , requestArticle destinationTitleInput Setup.Messages.FetchDestinationArticleResult
        ]
        |> Cmd.map Messages.SetupMsg
