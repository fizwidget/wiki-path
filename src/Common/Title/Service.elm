module Common.Title.Service exposing (requestRandom)

import RemoteData exposing (WebData)
import Common.Title.Api as Api
import Common.Title.Model exposing (Title)


requestRandom : (WebData (List Title) -> msg) -> Int -> Cmd msg
requestRandom toMsg articleCount =
    Api.buildRandomTitleRequest articleCount
        |> RemoteData.sendRequest
        |> Cmd.map toMsg
