module Commands exposing (fetchArticle)

import Http
import RemoteData
import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, requiredAt)
import Messages exposing (Message(FetchArticleResult))
import Model exposing (Article)


fetchArticle : String -> Cmd Message
fetchArticle title =
    Http.get (getArticleUrl title) articleDecoder
        |> RemoteData.sendRequest
        |> Cmd.map FetchArticleResult


getArticleUrl : String -> String
getArticleUrl title =
    "https://en.wikipedia.org/w/api.php?action=parse&format=json&formatversion=2&origin=*&page=" ++ title


articleDecoder : Decoder Article
articleDecoder =
    decode Article
        |> requiredAt [ "parse", "title" ] string
        |> requiredAt [ "parse", "text" ] string
