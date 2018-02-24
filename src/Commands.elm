module Commands exposing (fetchArticle)

import Jsonp
import RemoteData
import Messages exposing (Message(FetchArticleResult))
import Decoder exposing (responseDecoder, responseToArticle)


fetchArticle : String -> Cmd Message
fetchArticle title =
    title
        |> buildUrl
        |> Jsonp.get responseDecoder
        |> RemoteData.asCmd
        |> Cmd.map (RemoteData.map responseToArticle)
        |> Cmd.map FetchArticleResult


buildUrl : String -> String
buildUrl title =
    "https://en.wikipedia.org/w/api.php?action=query&titles=" ++ title ++ "&prop=revisions&rvprop=content&format=json&formatversion=2"
