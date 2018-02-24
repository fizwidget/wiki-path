module Commands exposing (fetchArticle)

import Jsonp
import Json.Decode exposing (int, string, float, nullable, list, Decoder)
import Json.Decode.Pipeline exposing (decode, required, requiredAt, optional, hardcoded)
import Messages exposing (Message(FetchArticleResult))
import RemoteData exposing (WebData)
import Model exposing (Article)


fetchArticle : String -> Cmd Message
fetchArticle title =
    title
        |> buildUrl
        |> Jsonp.get responseDecoder
        |> RemoteData.asCmd
        |> Cmd.map toFetchArticleResult
        |> Cmd.map FetchArticleResult


buildUrl : String -> String
buildUrl title =
    "https://en.wikipedia.org/w/api.php?action=query&titles=" ++ title ++ "&prop=revisions&rvprop=content&format=json&formatversion=2"


toFetchArticleResult : WebData Response -> WebData (Maybe Article)
toFetchArticleResult =
    RemoteData.map responseToArticle


responseToArticle : Response -> Maybe Article
responseToArticle response =
    let
        page : Maybe Page
        page =
            getFirstPage response

        title : Maybe String
        title =
            Maybe.map .title page

        revision : Maybe Revision
        revision =
            Maybe.andThen getFirstRevision page
    in
        Maybe.map2 (\t r -> { title = t, content = r.content }) title revision


getFirstPage : Response -> Maybe Page
getFirstPage response =
    response
        |> .query
        |> List.head


getFirstRevision : Page -> Maybe Revision
getFirstRevision page =
    page
        |> .revisions
        |> List.head


type alias Response =
    { query : List Page }


type alias Page =
    { title : String
    , revisions : List Revision
    }


type alias Revision =
    { content : String
    }


responseDecoder : Decoder Response
responseDecoder =
    decode Response
        |> requiredAt [ "query", "pages" ] pagesDecoder


pagesDecoder : Decoder (List Page)
pagesDecoder =
    list pageDecoder


pageDecoder : Decoder Page
pageDecoder =
    decode Page
        |> required "title" string
        |> required "revisions" revisionsDecoder


revisionsDecoder : Decoder (List Revision)
revisionsDecoder =
    list revisionDecoder


revisionDecoder : Decoder Revision
revisionDecoder =
    decode Revision
        |> required "content" string
