module Commands exposing (fetchArticle)

import Http
import RemoteData exposing (WebData)
import Model exposing (Article, RemoteArticle, Error(HttpError))
import Decoder exposing (remoteArticle)
import Messages exposing (Message)


-- Need to flatmap this or something?


fetchArticle : String -> (RemoteArticle -> Message) -> Cmd Message
fetchArticle title toMessage =
    Http.get (getArticleUrl title) remoteArticle
        |> RemoteData.sendRequest
        |> Cmd.map unpack
        |> Cmd.map toMessage


unpack : WebData RemoteArticle -> RemoteArticle
unpack =
    Debug.crash ("implement me")



-- :  (WebData RemoteArticle -> RemoteData Error Article)
--     -> RemoteData e a
--     -> RemoteData e b


getArticleUrl : String -> String
getArticleUrl title =
    "https://en.wikipedia.org/w/api.php?action=parse&format=json&formatversion=2&origin=*&page=" ++ title
