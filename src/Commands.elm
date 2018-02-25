module Commands exposing (fetchArticle)

import Http
import RemoteData exposing (WebData)
import Json.Decode exposing (Decoder, string, nullable)
import Json.Decode.Pipeline exposing (decode, required)
import Messages exposing (Message(..))
import Model exposing (Article)


fetchArticle : String -> (WebData (Maybe Article) -> Message) -> Cmd Message
fetchArticle title toMessage =
    fetchResponse title
        |> Cmd.map toArticle
        |> Cmd.map toMessage


toArticle : WebData Response -> WebData (Maybe Article)
toArticle response =
    RemoteData.map .parse response


fetchResponse : String -> Cmd (WebData Response)
fetchResponse title =
    Http.get (getArticleUrl title) responseDecoder
        |> RemoteData.sendRequest


getArticleUrl : String -> String
getArticleUrl title =
    "https://en.wikipedia.org/w/api.php?action=parse&format=json&formatversion=2&origin=*&page=" ++ title


responseDecoder : Decoder Response
responseDecoder =
    decode Response
        |> required "parse" (nullable articleDecoder)


articleDecoder : Decoder Article
articleDecoder =
    decode Article
        |> required "title" string
        |> required "text" string


type alias Response =
    { parse : Maybe Article
    }
