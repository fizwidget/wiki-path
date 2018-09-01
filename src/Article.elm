module Article
    exposing
        ( Article
        , Preview
        , Full
        , ArticleResult
        , ArticleError(..)
        , title
        , content
        , links
        , preview
        , equals
        , isDisambiguation
        , length
        , random
        , fetch
        , viewError
        , viewAsLink
        )

import Http
import RemoteData exposing (RemoteData, WebData)
import Json.Decode as Decode exposing (Decoder, field, at, map, bool, string, int, list, oneOf, succeed)
import Json.Decode.Pipeline exposing (decode, required, requiredAt, hardcoded, custom)
import Url exposing (Url, QueryParam(KeyValue, Key))
import Html.Styled exposing (Html, a, div, text)
import Html.Styled.Attributes exposing (href)


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
title (Article title _) =
    title


content : Article Full -> String
content (Article _ (Full { content })) =
    content


links : Article Full -> List (Article Preview)
links (Article _ (Full { links })) =
    links


preview : Article a -> Article Preview
preview (Article title _) =
    Article title Preview


equals : Article a -> Article b -> Bool
equals (Article firstTitle _) (Article secondTitle _) =
    firstTitle == secondTitle


isDisambiguation : Article Full -> Bool
isDisambiguation =
    content >> String.contains "{{disambiguation}}"


length : Article Full -> Int
length =
    content >> String.length



-- VIEW


viewAsLink : Article a -> Html msg
viewAsLink article =
    a
        [ href (toUrl article) ]
        [ text (title article) ]


toUrl : Article a -> String
toUrl article =
    "https://en.wikipedia.org/wiki/" ++ (title article)


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


fetch : String -> Http.Request ArticleResult
fetch title =
    Http.get (buildArticleUrl title) responseDecoder


buildArticleUrl : String -> Url
buildArticleUrl title =
    let
        queryParams =
            [ KeyValue ( "action", "query" )
            , KeyValue ( "format", "json" )
            , KeyValue ( "prop", "revisions|links" )
            , KeyValue ( "titles", title )
            , KeyValue ( "redirects", "1" )
            , KeyValue ( "formatversion", "2" )
            , KeyValue ( "rvprop", "content" )
            , KeyValue ( "rvslots", "main" )
            , KeyValue ( "plnamespace", "0" )
            , KeyValue ( "pllimit", "max" )
            , KeyValue ( "origin", "*" )
            ]
    in
        Url.build "https://en.wikipedia.org/w/api.php" queryParams


responseDecoder : Decoder ArticleResult
responseDecoder =
    at [ "query", "pages", "0" ] <|
        oneOf
            [ map Ok successDecoder
            , map Err invalidDecoder
            , map Err missingDecoder
            ]


successDecoder : Decoder (Article Full)
successDecoder =
    succeed Article
        |> required "title" string
        |> custom (map Full bodyDecoder)


invalidDecoder : Decoder ArticleError
invalidDecoder =
    field "invalid" bool
        |> Decode.andThen
            (always <| Decode.succeed InvalidTitle)


missingDecoder : Decoder ArticleError
missingDecoder =
    field "missing" bool
        |> Decode.andThen
            (always <| Decode.succeed ArticleNotFound)


bodyDecoder : Decoder Body
bodyDecoder =
    decode Body
        |> requiredAt [ "revisions", "0", "slots", "main", "content" ] string
        |> required "links" (list previewDecoder)


random : Int -> Http.Request (List (Article Preview))
random count =
    Http.get (buildRandomArticlesUrl count) randomArticlesDecoder


buildRandomArticlesUrl : Int -> Url
buildRandomArticlesUrl articleCount =
    let
        queryParams =
            [ KeyValue ( "action", "query" )
            , KeyValue ( "format", "json" )
            , KeyValue ( "list", "random" )
            , KeyValue ( "rnlimit", toString articleCount )
            , KeyValue ( "rnnamespace", "0" )
            , KeyValue ( "origin", "*" )
            ]
    in
        Url.build "https://en.wikipedia.org/w/api.php" queryParams


randomArticlesDecoder : Decoder (List (Article Preview))
randomArticlesDecoder =
    at
        [ "query", "random" ]
        (list previewDecoder)


previewDecoder : Decoder (Article Preview)
previewDecoder =
    succeed Article
        |> required "title" string
        |> hardcoded Preview
