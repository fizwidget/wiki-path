module Finished.Init exposing (initWithPath, initWithPathNotFoundError, initWithTooManyRequestsError)

import Common.Path.Model exposing (Path)
import Model exposing (Model(Finished))
import Messages exposing (Msg)
import Finished.Model exposing (FinishedModel(Success, Error), Error(PathNotFound, TooManyRequests))


initWithPath : Path -> ( Model, Cmd Msg )
initWithPath pathToDestination =
    ( Finished <| Success pathToDestination, Cmd.none )


initWithPathNotFoundError : ( Model, Cmd Msg )
initWithPathNotFoundError =
    ( Finished <| Error PathNotFound, Cmd.none )


initWithTooManyRequestsError : ( Model, Cmd Msg )
initWithTooManyRequestsError =
    ( Finished <| Error TooManyRequests, Cmd.none )
