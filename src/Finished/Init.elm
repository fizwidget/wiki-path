module Finished.Init exposing (initWithPath, initWithPathNotFound, initWithTooManyRequestsError)

import Common.Path.Model exposing (Path)
import Model exposing (Model(Finished))
import Messages exposing (Msg)
import Finished.Model exposing (FinishedModel(Success, Error), Error(PathNotFound, TooManyRequests))


initWithPath : Path -> ( Model, Cmd Msg )
initWithPath path =
    ( Finished <| Success path, Cmd.none )


initWithPathNotFound : ( Model, Cmd Msg )
initWithPathNotFound =
    ( Finished <| Error PathNotFound, Cmd.none )


initWithTooManyRequestsError : ( Model, Cmd Msg )
initWithTooManyRequestsError =
    ( Finished <| Error TooManyRequests, Cmd.none )
