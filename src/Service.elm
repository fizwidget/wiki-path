module Service exposing (getArticle)

import RemoteData
import Model exposing (RemoteArticle)
import Messages exposing (Msg)
import Api


getArticle : String -> (RemoteArticle -> Msg) -> Cmd Msg
getArticle title createMsg =
    Api.fetchArticle title
        |> RemoteData.sendRequest
        |> Cmd.map createMsg
