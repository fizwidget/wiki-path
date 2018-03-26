module PathfindingPage.Transition exposing (transition)

import RemoteData
import Common.Model exposing (Title, Article, ArticleError)
import PathfindingPage.Model exposing (Model, Error(..))
import PathfindingPage.Messages exposing (Msg(ArticleReceived))
import PathfindingPage.Util exposing (hasFinished)


type alias Path =
    { start : Title
    , end : Title
    , stops : List Title
    }


type alias Transition =
    Path


transition : Msg -> Model -> Maybe Transition
transition message model =
    case message of
        ArticleReceived remoteArticle ->
            case remoteArticle of
                RemoteData.NotAsked ->
                    Nothing

                RemoteData.Loading ->
                    Nothing

                RemoteData.Success article ->
                    if article.title == model.end.title then
                        Just (toTransition model)
                    else
                        Nothing

                RemoteData.Failure error ->
                    Nothing


toTransition : Model -> Transition
toTransition { start, end, stops } =
    { start = start.title
    , end = end.title
    , stops = stops
    }
