module WelcomePage.Update exposing (update)

import RemoteData
import Common.Model exposing (Article)
import Common.Service exposing (requestArticle)
import WelcomePage.Messages exposing (Msg(..))
import WelcomePage.Model exposing (Model)


type alias Transition =
    { start : Article
    , end : Article
    }


update : Msg -> Model -> ( Model, Cmd Msg, Maybe Transition )
update message model =
    case message of
        StartArticleTitleChange value ->
            ( { model | startTitleInput = value }, Cmd.none, Nothing )

        EndArticleTitleChange value ->
            ( { model | endTitleInput = value }, Cmd.none, Nothing )

        FetchArticlesRequest ->
            ( model, getArticles model, Nothing )

        FetchStartArticleResult article ->
            ( { model | startArticle = article }, Cmd.none )
                |> transitionIfDone

        FetchEndArticleResult article ->
            ( { model | endArticle = article }, Cmd.none )
                |> transitionIfDone


getArticles : Model -> Cmd Msg
getArticles { startTitleInput, endTitleInput } =
    Cmd.batch
        [ requestArticle FetchStartArticleResult startTitleInput
        , requestArticle FetchEndArticleResult endTitleInput
        ]


transitionIfDone : ( Model, Cmd Msg ) -> ( Model, Cmd Msg, Maybe Transition )
transitionIfDone ( model, cmd ) =
    let
        transition =
            RemoteData.map2 Transition model.startArticle model.endArticle
                |> RemoteData.toMaybe
    in
        ( model, cmd, transition )
