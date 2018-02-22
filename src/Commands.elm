module Commands exposing (fetchArticle)

import Jsonp
import Json.Decode exposing (int, string, float, nullable, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
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


type alias Article =
    { title : String
    , content : String
    }


type alias Pages =
    { pages : List Article
    }


articleDecoder : Decoder Article
articleDecoder =
    decode Article
        |> required "query" queryDecoder


queryDecoder : Decoder Pages
queryDecoder =
    decode Pages
        |> required "pages" Pages
