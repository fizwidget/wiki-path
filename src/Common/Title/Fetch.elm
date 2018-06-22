module Common.Title.Fetch exposing (titlePair)

import RemoteData exposing (WebData)
import Common.Title.Model exposing (Title, RemoteTitlePair, TitleError(HttpError, UnexpectedTitleCount))
import Common.Title.Api as TitleApi


titlePair : (RemoteTitlePair -> msg) -> Cmd msg
titlePair toMsg =
    TitleApi.buildRandomTitleRequest 2
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteTitlePair >> toMsg)


toRemoteTitlePair : WebData (List Title) -> RemoteTitlePair
toRemoteTitlePair remoteTitles =
    let
        toPair titles =
            case titles of
                titleA :: titleB :: _ ->
                    RemoteData.succeed ( titleA, titleB )

                _ ->
                    RemoteData.Failure UnexpectedTitleCount
    in
        remoteTitles
            |> RemoteData.mapError Common.Title.Model.HttpError
            |> RemoteData.andThen toPair
