module Article exposing
    ( Article
    , ArticleError(..)
    , ArticleResult
    , Full
    , Preview
    , equals
    , fetchNamed
    , fetchRandom
    , getContent
    , getLength
    , getLinks
    , getTitle
    , isDisambiguation
    , preview
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
import Url.Builder as UrlBuilder exposing (QueryParameter)



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


getTitle : Article a -> String
getTitle (Article title _) =
    title


getContent : Article Full -> String
getContent (Article _ (Full { content })) =
    content


getLinks : Article Full -> List (Article Preview)
getLinks (Article _ (Full { links })) =
    links


getLength : Article Full -> Int
getLength =
    getContent >> String.length


isDisambiguation : Article Full -> Bool
isDisambiguation =
    getContent >> String.contains "{{disambiguation}}"


preview : Article a -> Article Preview
preview (Article title _) =
    Article title Preview


equals : Article a -> Article b -> Bool
equals (Article firstTitle _) (Article secondTitle _) =
    firstTitle == secondTitle



-- VIEW


viewAsLink : Article a -> Html msg
viewAsLink article =
    a
        [ href (toUrl article) ]
        [ text (getTitle article) ]


toUrl : Article a -> String
toUrl article =
    "https://en.wikipedia.org/wiki/" ++ getTitle article


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



-- FETCH


fetchNamed : String -> Http.Request ArticleResult
fetchNamed title =
    Http.get (namedArticleUrl title) namedArticleDecoder


fetchRandom : Int -> Http.Request (List (Article Preview))
fetchRandom count =
    Http.get (randomArticlesUrl count) randomArticlesDecoder


type alias ArticleResult =
    Result ArticleError (Article Full)


type ArticleError
    = ArticleNotFound
    | InvalidTitle
    | HttpError Http.Error



-- URLS


randomArticlesUrl : Int -> String
randomArticlesUrl articleCount =
    wikipediaQuery
        [ UrlBuilder.string "list" "random"
        , UrlBuilder.int "rnlimit" articleCount
        , UrlBuilder.int "rnnamespace" 0
        ]


namedArticleUrl : Title -> String
namedArticleUrl title =
    wikipediaQuery
        [ UrlBuilder.string "prop" "revisions|links"
        , UrlBuilder.string "titles" title
        , UrlBuilder.int "redirects" 1
        , UrlBuilder.int "formatversion" 2
        , UrlBuilder.string "rvprop" "content"
        , UrlBuilder.string "rvslots" "main"
        , UrlBuilder.int "plnamespace" 0
        , UrlBuilder.string "pllimit" "max"
        ]


wikipediaQuery : List QueryParameter -> String
wikipediaQuery params =
    let
        baseParams =
            [ UrlBuilder.string "action" "query"
            , UrlBuilder.string "format" "json"
            , UrlBuilder.string "origin" "*"
            ]
    in
    UrlBuilder.crossOrigin "https://en.wikipedia.org" [ "w", "api.php" ] (baseParams ++ params)



-- DECODERS


namedArticleDecoder : Decoder ArticleResult
namedArticleDecoder =
    at [ "query", "pages", "0" ]
        (oneOf
            [ map Ok fullArticleDecoder
            , map Err invalidArticleDecoder
            , map Err missingArticleDecoder
            ]
        )


randomArticlesDecoder : Decoder (List (Article Preview))
randomArticlesDecoder =
    at [ "query", "random" ] (list previewArticleDecoder)


previewArticleDecoder : Decoder (Article Preview)
previewArticleDecoder =
    succeed Article
        |> required "title" string
        |> hardcoded Preview


fullArticleDecoder : Decoder (Article Full)
fullArticleDecoder =
    succeed Article
        |> required "title" string
        |> custom (map Full bodyDecoder)


bodyDecoder : Decoder Body
bodyDecoder =
    succeed Body
        |> requiredAt [ "revisions", "0", "slots", "main", "content" ] string
        |> required "links" (list previewArticleDecoder)


invalidArticleDecoder : Decoder ArticleError
invalidArticleDecoder =
    field "invalid" bool
        |> Decode.andThen
            (always <| Decode.succeed InvalidTitle)


missingArticleDecoder : Decoder ArticleError
missingArticleDecoder =
    field "missing" bool
        |> Decode.andThen
            (always <| Decode.succeed ArticleNotFound)
