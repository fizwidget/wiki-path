module Commands exposing (fetchArticle)

import Http
import RemoteData exposing (WebData)
import Model exposing (RemoteArticle)
import Decoder exposing (remoteArticle)
import Messages exposing (Message)


fetchArticle : String -> (RemoteArticle -> Message) -> Cmd Message
fetchArticle title toMessage =
    Http.get (getArticleUrl title) remoteArticle
        |> RemoteData.sendRequest
        |> Cmd.map toMessage


getArticleUrl : String -> String
getArticleUrl title =
    "https://en.wikipedia.org/w/api.php?action=parse&format=json&formatversion=2&origin=*&page=" ++ title
