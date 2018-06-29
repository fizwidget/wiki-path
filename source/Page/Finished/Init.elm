module Page.Finished.Init exposing (initWithPath, initWithPathNotFoundError, initWithTooManyRequestsError)

import Common.Article.Model exposing (Article)
import Common.Path.Model exposing (Path)
import Model exposing (Model(Finished))
import Messages exposing (Msg)
import Page.Finished.Model exposing (FinishedModel(Success, Error), Error(PathNotFound, TooManyRequests))


initWithPath : Path -> ( Model, Cmd Msg )
initWithPath pathToDestination =
    ( Finished <| Success pathToDestination, Cmd.none )


initWithPathNotFoundError : Article -> Article -> ( Model, Cmd Msg )
initWithPathNotFoundError source destination =
    initWithError source destination PathNotFound


initWithTooManyRequestsError : Article -> Article -> ( Model, Cmd Msg )
initWithTooManyRequestsError source destination =
    initWithError source destination TooManyRequests


initWithError : Article -> Article -> Error -> ( Model, Cmd Msg )
initWithError source destination error =
    ( Finished <|
        Error
            { source = source
            , destination = destination
            , error = error
            }
    , Cmd.none
    )
