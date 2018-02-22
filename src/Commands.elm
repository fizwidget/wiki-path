module Commands exposing (fetchArticle)

import Jsonp
import Messages exposing (Message(FetchArticleResult))
import Model exposing (Url)
import RemoteData


fetchArticle : String -> Cmd Message
fetchArticle articleTitle =
    getUrl articleTitle
        |> Jsonp.get
        |> RemoteData.sendRequest
        |> Cmd.map FetchArticleResult


getUrl : String -> String
getUrl articleTitle =
    "https://en.wikipedia.org/w/api.php?action=query&titles=" ++ articleTitle ++ "&prop=revisions&rvprop=content&format=json&formatversion=2"
