module Pathfinding.Update exposing (update, updateWithArticle)

import Result exposing (Result(Ok, Err))
import Common.Article.Service as ArticleService
import Common.Article.Model exposing (Article, ArticleError)
import Common.Title.Model as Title exposing (Title)
import Common.PriorityQueue.Model as PriorityQueue
import Model exposing (Model)
import Messages exposing (Msg(..))
import Pathfinding.Util exposing (addLinks)
import Pathfinding.Messages exposing (PathfindingMsg(..))
import Pathfinding.Model exposing (PathfindingModel, Path, Error(..))


update : PathfindingMsg -> PathfindingModel -> ( Model, Cmd Msg, Maybe (List Title) )
update message model =
    case message of
        FetchArticleResponse pathSoFar articleResult ->
            case articleResult of
                Ok article ->
                    updateWithArticle model pathSoFar article

                Err error ->
                    updateWithError model error


updateWithArticle : PathfindingModel -> Path -> Article -> ( Model, Cmd Msg, Maybe (List Title) )
updateWithArticle model pathSoFar article =
    let
        updatedPriorityQueue =
            addLinks
                model.priorityQueue
                model.destination
                pathSoFar
                article.links

        updatedModel =
            { model | priorityQueue = updatedPriorityQueue }
    in
        followHighestPriorityPath updatedModel


updateWithError : PathfindingModel -> ArticleError -> ( Model, Cmd Msg, Maybe (List Title) )
updateWithError model error =
    let
        updatedModel =
            { model | errors = error :: model.errors }
    in
        followHighestPriorityPath updatedModel


followHighestPriorityPath : PathfindingModel -> ( Model, Cmd Msg, Maybe (List Title) )
followHighestPriorityPath model =
    let
        ( highestPriorityPath, updatedPriorityQueue ) =
            PriorityQueue.removeHighestPriority model.priorityQueue

        updatedModel =
            { model | priorityQueue = updatedPriorityQueue }
    in
        highestPriorityPath
            |> Maybe.map (followPath updatedModel)
            |> Maybe.withDefault (pathNotFound updatedModel)


followPath : PathfindingModel -> Path -> ( Model, Cmd Msg, Maybe (List Title) )
followPath model pathToFollow =
    if hasReachedDestination pathToFollow model.destination then
        ( Model.Pathfinding model
        , Cmd.none
        , Just <| List.reverse <| pathToFollow.next :: pathToFollow.visited
        )
    else
        ( Model.Pathfinding model, fetchNextArticle pathToFollow, Nothing )


fetchNextArticle : Path -> Cmd Msg
fetchNextArticle pathSoFar =
    let
        toMsg =
            FetchArticleResponse pathSoFar >> Messages.Pathfinding

        title =
            Title.value pathSoFar.next
    in
        ArticleService.request toMsg title


hasReachedDestination : Path -> Article -> Bool
hasReachedDestination pathSoFar destination =
    pathSoFar.next == destination.title


pathNotFound : PathfindingModel -> ( Model, Cmd Msg, Maybe (List Title) )
pathNotFound model =
    ( Model.Pathfinding { model | fatalError = Just PathNotFound }
    , Cmd.none
    , Nothing
    )
