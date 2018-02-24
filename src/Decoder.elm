module Decoder exposing (responseDecoder)

import Json.Decode exposing (int, string, float, nullable, list, Decoder)
import Json.Decode.Pipeline exposing (decode, required, requiredAt, optional, hardcoded)
import Model exposing (Article)


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


responseToArticle : Response -> Maybe Article
responseToArticle response =
    let
        page =
            getFirstPage response

        title =
            Maybe.map .title page

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
