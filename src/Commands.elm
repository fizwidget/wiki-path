module Commands exposing (fetchArticle)

import Http
import Messages exposing (Message(FetchArticleResult))
import Model exposing (Url)
import RemoteData


fetchArticle : Url -> Cmd Message
fetchArticle url =
    Http.getString url
        |> RemoteData.sendRequest
        |> Cmd.map FetchArticleResult
