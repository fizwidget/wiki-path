module Article exposing
    ( Article
    , ArticleError(..)
    , ArticleResult
    , Full
    , Preview
    , content
    , equals
    , fetchByTitle
    , fetchRandom
    , isDisambiguation
    , length
    , links
    , preview
    , title
    , viewAsLink
    , viewError
    )

import Css exposing (..)
import Html.Styled exposing (Html, a, span, text)
import Html.Styled.Attributes exposing (css, href)
import Http
import Json.Decode as Decode exposing (Decoder, at, bool, field, int, list, map, oneOf, string, succeed)
import Json.Decode.Pipeline exposing (custom, hardcoded, required, requiredAt)
import Url exposing (Url)
import Url.Builder as Url exposing (QueryParameter)



-- TYPES


type Article a
    = Article Title a


type Preview
    = Preview


type Full
    = Full Body


type alias Body =
    { content : Wikitext
    , links : List (Article Preview)
    }


type alias Title =
    String


type alias Wikitext =
    String



-- INFO


title : Article a -> String
title (Article value _) =
    value


content : Article Full -> String
content (Article _ (Full body)) =
    body.content


links : Article Full -> List (Article Preview)
links (Article _ (Full body)) =
    body.links


length : Article Full -> Int
length =
    content >> String.length


isDisambiguation : Article Full -> Bool
isDisambiguation article =
    let
        contains text =
            String.contains text (content article)
    in
    List.any contains
        [ "disambiguation}}"
        , "{{Disambiguation"
        , "{{disambig}}"
        , "{{dmbox"
        ]


preview : Article a -> Article Preview
preview (Article value _) =
    Article value Preview


equals : Article a -> Article b -> Bool
equals (Article firstTitle _) (Article secondTitle _) =
    firstTitle == secondTitle



-- VIEW


viewAsLink : Article a -> Html msg
viewAsLink article =
    a
        [ href (toUrl article) ]
        [ text (title article) ]


toUrl : Article a -> String
toUrl article =
    "https://en.wikipedia.org/wiki/" ++ title article


viewError : ArticleError -> Html msg
viewError error =
    span
        [ css [ fontSize (px 16) ] ]
        [ text (toErrorMessage error) ]


toErrorMessage : ArticleError -> String
toErrorMessage error =
    case error of
        ArticleNotFound ->
            "Couldn't find that article 😕"

        InvalidTitle ->
            "Not a valid article title 😕"

        HttpError _ ->
            "Network error 😕"



-- FETCH RANDOM


fetchRandom : Int -> Http.Request (List (Article Preview))
fetchRandom count =
    Http.get (fetchRandomUrl count) fetchRandomDecoder


fetchRandomUrl : Int -> Url
fetchRandomUrl count =
    wikipediaQueryUrl
        [ Url.string "list" "random"
        , Url.int "rnlimit" count
        , Url.int "rnnamespace" 0
        ]


fetchRandomDecoder : Decoder (List (Article Preview))
fetchRandomDecoder =
    at [ "query", "random" ] (list previewDecoder)



-- FETCH BY TITLE


fetchByTitle : Title -> Http.Request ArticleResult
fetchByTitle articleTitle =
    Http.get (fetchByTitleUrl articleTitle) fetchByTitleDecoder


fetchByTitleUrl : Title -> Url
fetchByTitleUrl articleTitle =
    wikipediaQueryUrl
        [ Url.string "prop" "revisions|links"
        , Url.string "titles" articleTitle
        , Url.int "redirects" 1
        , Url.int "formatversion" 2
        , Url.string "rvprop" "content"
        , Url.string "rvslots" "main"
        , Url.int "plnamespace" 0
        , Url.string "pllimit" "max"
        ]


fetchByTitleDecoder : Decoder ArticleResult
fetchByTitleDecoder =
    at [ "query", "pages", "0" ] <|
        oneOf
            [ map Ok fullDecoder
            , map Err invalidDecoder
            , map Err missingDecoder
            ]


invalidDecoder : Decoder ArticleError
invalidDecoder =
    field "invalid" bool
        |> Decode.andThen (always (Decode.succeed InvalidTitle))


missingDecoder : Decoder ArticleError
missingDecoder =
    field "missing" bool
        |> Decode.andThen (always (Decode.succeed ArticleNotFound))


type alias ArticleResult =
    Result ArticleError (Article Full)


type ArticleError
    = ArticleNotFound
    | InvalidTitle
    | HttpError Http.Error



-- API UTILS


wikipediaQueryUrl : List QueryParameter -> Url
wikipediaQueryUrl customParams =
    let
        baseParams =
            [ Url.string "action" "query"
            , Url.string "format" "json"
            , Url.string "origin" "*"
            ]
    in
    Url.crossOrigin "https://en.wikipedia.org" [ "w", "api.php" ] (baseParams ++ customParams)


type alias Url =
    String



-- ARTICLE DECODERS


previewDecoder : Decoder (Article Preview)
previewDecoder =
    succeed Article
        |> required "title" string
        |> hardcoded Preview


fullDecoder : Decoder (Article Full)
fullDecoder =
    succeed Article
        |> required "title" string
        |> custom (map Full bodyDecoder)


bodyDecoder : Decoder Body
bodyDecoder =
    succeed Body
        |> requiredAt [ "revisions", "0", "slots", "main", "content" ] string
        |> required "links" (list previewDecoder)
