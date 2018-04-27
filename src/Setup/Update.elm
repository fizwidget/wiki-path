module Setup.Update exposing (update)

import RemoteData exposing (RemoteData(Loading, NotAsked))
import Common.Article.Service as ArticleService
import Common.Article.Model exposing (Article, RemoteArticle)
import Setup.Messages exposing (SetupMsg(..))
import Setup.Model exposing (SetupModel, UserInput)


type alias Articles =
    { source : Article
    , destination : Article
    }


update : SetupMsg -> SetupModel -> ( SetupModel, Cmd SetupMsg, Maybe Articles )
update message model =
    case message of
        SourceArticleTitleChange value ->
            setSourceTitle model value

        DestinationArticleTitleChange value ->
            setDestinationTitle model value

        FetchArticlesRequest ->
            loadArticles model

        FetchSourceArticleResult article ->
            (setSourceArticle model article)

        FetchDestinationArticleResult article ->
            setDestinationArticle model article


setSourceTitle : SetupModel -> UserInput -> ( SetupModel, Cmd SetupMsg, Maybe Articles )
setSourceTitle model sourceTitleInput =
    ( { model
        | source = NotAsked
        , sourceTitleInput = sourceTitleInput
      }
    , Cmd.none
    , Nothing
    )


setDestinationTitle : SetupModel -> UserInput -> ( SetupModel, Cmd SetupMsg, Maybe Articles )
setDestinationTitle model destinationTitleInput =
    ( { model
        | destination = NotAsked
        , destinationTitleInput = destinationTitleInput
      }
    , Cmd.none
    , Nothing
    )


loadArticles : SetupModel -> ( SetupModel, Cmd SetupMsg, Maybe Articles )
loadArticles model =
    ( { model
        | source = Loading
        , destination = Loading
      }
    , requestArticles model
    , Nothing
    )


requestArticles : SetupModel -> Cmd SetupMsg
requestArticles { sourceTitleInput, destinationTitleInput } =
    Cmd.batch
        [ ArticleService.requestRemote FetchSourceArticleResult sourceTitleInput
        , ArticleService.requestRemote FetchDestinationArticleResult destinationTitleInput
        ]


setSourceArticle : SetupModel -> RemoteArticle -> ( SetupModel, Cmd SetupMsg, Maybe Articles )
setSourceArticle model source =
    ( { model | source = source }, Cmd.none )
        |> beginPathfindingIfArticlesLoaded


setDestinationArticle : SetupModel -> RemoteArticle -> ( SetupModel, Cmd SetupMsg, Maybe Articles )
setDestinationArticle model destination =
    ( { model | destination = destination }, Cmd.none )
        |> beginPathfindingIfArticlesLoaded


beginPathfindingIfArticlesLoaded : ( SetupModel, Cmd SetupMsg ) -> ( SetupModel, Cmd SetupMsg, Maybe Articles )
beginPathfindingIfArticlesLoaded ( model, cmd ) =
    RemoteData.map2 Articles model.source model.destination
        |> RemoteData.toMaybe
        |> Maybe.map (\articles -> ( model, cmd, Just articles ))
        |> Maybe.withDefault ( model, cmd, Nothing )
