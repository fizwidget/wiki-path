module Setup.State exposing (initialModel, update)

import RemoteData
import Common.Service exposing (requestArticle)
import Setup.Types exposing (Msg(..))


initialModel : Setup.Types.Model
initialModel =
    { sourceTitleInput = ""
    , destinationTitleInput = ""
    , sourceArticle = RemoteData.NotAsked
    , destinationArticle = RemoteData.NotAsked
    }


update : Setup.Types.Msg -> Setup.Types.Model -> ( Setup.Types.Model, Cmd Setup.Types.Msg, Maybe Setup.Types.Transition )
update message model =
    case message of
        FetchArticlesRequest ->
            ( model, getArticles model, Nothing )

        FetchSourceArticleResult article ->
            ( { model | sourceArticle = article }, Cmd.none, Nothing )

        FetchDestinationArticleResult article ->
            ( { model | destinationArticle = article }, Cmd.none, Nothing )

        SourceArticleTitleChange value ->
            ( { model | sourceTitleInput = value }, Cmd.none, Nothing )

        DestinationArticleTitleChange value ->
            ( { model | destinationTitleInput = value }, Cmd.none, Nothing )


getArticles : Setup.Types.Model -> Cmd Setup.Types.Msg
getArticles { sourceTitleInput, destinationTitleInput } =
    Cmd.batch
        [ requestArticle sourceTitleInput FetchSourceArticleResult
        , requestArticle destinationTitleInput FetchDestinationArticleResult
        ]


transition : Setup.Types.Model -> Maybe Setup.Types.Transition
transition { sourceArticle, destinationArticle } =
    RemoteData.map2 Setup.Types.Transition sourceArticle destinationArticle
        |> RemoteData.toMaybe
