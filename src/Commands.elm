module Commands exposing (fetchArticle)

import Jsonp
import Messages exposing (Message(FetchArticleResult))
import Model exposing (Url)
import RemoteData


fetchArticle : Url -> Cmd Message
fetchArticle url =
    Jsonp.getString url
        |> RemoteData.sendRequest
        |> Cmd.map FetchArticleResult
