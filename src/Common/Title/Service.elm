module Common.Title.Service exposing (requestRandomPair)

import RemoteData exposing (WebData, RemoteData)
import Common.Title.Api as Api
import Common.Title.Model exposing (Title, RemoteTitlePair, TitleError(HttpError, UnexpectedTitleCount))


requestRandomPair : (RemoteTitlePair -> msg) -> Cmd msg
requestRandomPair toMsg =
    Api.buildRandomTitleRequest 2
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
            |> RemoteData.mapError HttpError
            |> RemoteData.andThen toPair
