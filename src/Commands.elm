module Commands exposing (getArticle)

import RemoteData
import Model exposing (RemoteArticle)
import Messages exposing (Message)
import Api exposing (fetchArticle)


getArticle : String -> (RemoteArticle -> Message) -> Cmd Message
getArticle title createMessage =
    fetchArticle title
        |> RemoteData.sendRequest
        |> Cmd.map createMessage
