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
    , getLinks
    , getTitle
    , isDisambiguation
    , length
    , preview
    , viewAsLink
    , viewError
    )

import Html.Styled exposing (Html, a, div, text)
import Html.Styled.Attributes exposing (href)
import Http
import Json.Decode as Decode exposing (Decoder, at, bool, field, int, list, map, oneOf, string, succeed)
import Json.Decode.Pipeline exposing (custom, hardcoded, required, requiredAt)
import Url exposing (Url)
import Url.Builder



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


preview : Article a -> Article Preview
preview (Article title _) =
    Article title Preview


equals : Article a -> Article b -> Bool
equals (Article firstTitle _) (Article secondTitle _) =
    firstTitle == secondTitle


length : Article Full -> Int
length =
    getContent >> String.length


isDisambiguation : Article Full -> Bool
isDisambiguation =
    getContent >> String.contains "{{disambiguation}}"



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
    div [] [ text (toErrorMessage error) ]


toErrorMessage : ArticleError -> String
toErrorMessage error =
    case error of
        ArticleNotFound ->
            "Couldn't find that article :("

        InvalidTitle ->
            "Not a valid article title :("

        HttpError _ ->
            "Network error :("



-- FETCH


type alias ArticleResult =
    Result ArticleError (Article Full)


type ArticleError
    = ArticleNotFound
    | InvalidTitle
    | HttpError Http.Error


fetchNamed : String -> Http.Request ArticleResult
fetchNamed title =
    Http.get (namedArticleUrl title) namedArticlesDecoder


fetchRandom : Int -> Http.Request (List (Article Preview))
fetchRandom count =
    Http.get (randomArticlesUrl count) randomArticlesDecoder



-- URLS


randomArticlesUrl : Int -> String
randomArticlesUrl articleCount =
    let
        queryParams =
            [ Url.Builder.string "action" "query"
            , Url.Builder.string "format" "json"
            , Url.Builder.string "list" "random"
            , Url.Builder.int "rnlimit" articleCount
            , Url.Builder.string "rnnamespace" "0"
            , Url.Builder.string "origin" "*"
            ]
    in
    Url.Builder.crossOrigin "https://en.wikipedia.org" [ "w", "api.php" ] queryParams


namedArticleUrl : Title -> String
namedArticleUrl title =
    let
        queryParams =
            [ Url.Builder.string "action" "query"
            , Url.Builder.string "format" "json"
            , Url.Builder.string "prop" "revisions|links"
            , Url.Builder.string "titles" title
            , Url.Builder.string "redirects" "1"
            , Url.Builder.string "formatversion" "2"
            , Url.Builder.string "rvprop" "content"
            , Url.Builder.string "rvslots" "main"
            , Url.Builder.string "plnamespace" "0"
            , Url.Builder.string "pllimit" "max"
            , Url.Builder.string "origin" "*"
            ]
    in
    Url.Builder.crossOrigin "https://en.wikipedia.org" [ "w", "api.php" ] queryParams


wikipediaApi : String
wikipediaApi =
    "https://en.wikipedia.org/w/api.php"



-- DECODERS


namedArticlesDecoder : Decoder ArticleResult
namedArticlesDecoder =
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
