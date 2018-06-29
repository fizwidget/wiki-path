module Page.Finished.Init
    exposing
        ( initWithPath
        , initWithPathNotFoundError
        , initWithTooManyRequestsError
        )

import Common.Article.Model exposing (Article)
import Common.Path.Model exposing (Path)
import Model exposing (Model(Finished))
import Messages exposing (Msg)
import Page.Finished.Model exposing (FinishedModel(Success, Error), Error(PathNotFound, TooManyRequests))


initWithPath : Path -> ( Model, Cmd Msg )
initWithPath pathToDestination =
    ( Finished <| Success pathToDestination
    , Cmd.none
    )


initWithPathNotFoundError : Article -> Article -> ( Model, Cmd Msg )
initWithPathNotFoundError =
    initWithError PathNotFound


initWithTooManyRequestsError : Article -> Article -> ( Model, Cmd Msg )
initWithTooManyRequestsError =
    initWithError TooManyRequests


initWithError : Error -> Article -> Article -> ( Model, Cmd Msg )
initWithError error source destination =
    ( Finished <| Error { source = source, destination = destination, error = error }
    , Cmd.none
    )
