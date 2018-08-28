module Article
    exposing
        ( Article
        , Full
        , Preview
        , Namespace(..)
        , ArticleResult
        , RemoteArticle
        , ArticleError(..)
        , title
        , equals
        , getArticleLinks
        , getFullArticle
        , viewError
        )

import Http
import RemoteData exposing (RemoteData, WebData)
import Json.Decode exposing (Decoder, field, at, map, bool, string, int, list, oneOf)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Url exposing (Url, QueryParam(KeyValue, Key))
import Html.Styled exposing (Html, div, text, a)
import Html.Styled.Attributes exposing (href)
import Article.Id as Id exposing (Id)


-- TYPES


type Article a
    = Article Metadata a


type alias Metadata =
    { id : Id
    , title : String
    }


type Preview
    = Preview


type Links
    = Links (List (Article Preview))


type Full
    = Full
        { content : Wikitext
        , links : List (Article Preview)
        }


type alias Wikitext =
    String



-- ACCESSORS


id : Article a -> Id
id (Article { id } _) =
    id


title : Article a -> String
title (Article { title } _) =
    title


body : Article Full -> HtmlString
body (Article _ (Full { body })) =
    body


equals : Article a -> Article b -> Bool
equals first second =
    id first == id second


asPreview : Article a -> Article Preview
asPreview (Article metadata _) =
    Article metadata Preview



-- VIEW


viewAsLink : Article a -> Html msg
viewAsLink (Article { title } _) =
    a
        [ href (toUrl title) ]
        [ text title ]


toUrl : String -> String
toUrl title =
    "https://en.wikipedia.org/wiki/" ++ title


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

        UnknownError _ ->
            "Unknown error \x1F92F"

        ArticleHttpError _ ->
            "Network error 😭"



-- API


type alias ArticleResult a =
    Result ArticleError (Article a)


type alias RemoteArticle a =
    RemoteData ArticleError (Article a)


type ArticleError
    = ArticleNotFound
    | InvalidTitle
    | UnknownError String
    | ArticleHttpError Http.Error



-- API (LINKS)


getArticleLinks : (ArticleResult Links -> msg) -> Article Preview -> Cmd msg
getArticleLinks toMsg article =
    article
        |> buildLinksRequest
        |> Http.send (toArticleResult >> toMsg)


toArticleResult : Result Http.Error (ArticleResult Links) -> ArticleResult Links
toArticleResult result =
    result
        |> Result.mapError ArticleHttpError
        |> Result.andThen identity


buildLinksRequest : Article Preview -> Http.Request (ArticleResult Links)
buildLinksRequest article =
    Http.get (buildArticleLinksUrl article) articleResponseDecoder


buildArticleLinksUrl : Article Preview -> Url
buildArticleLinksUrl article =
    let
        queryParams =
            [ KeyValue ( "action", "query" )
            , KeyValue ( "format", "json" )
            , KeyValue ( "prop", "links" )
            , KeyValue ( "origin", "*" )
            , KeyValue ( "formatversion", "2" )
            , KeyValue ( "plnamespace", "0" )
            , KeyValue ( "pllimit", "max" )
            , KeyValue ( "redirects", "1" )
            , KeyValue ( "pageids", id article )
            ]
    in
        Url.build "https://en.wikipedia.org/w/api.php" queryParams



-- API (FULL)


getFullArticle : (RemoteArticle Full -> msg) -> Article Preview -> Cmd msg
getFullArticle toMsg article =
    article
        |> buildFullArticleRequest
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteArticle >> toMsg)


toRemoteArticle : WebData (ArticleResult Full) -> RemoteArticle Full
toRemoteArticle webData =
    webData
        |> RemoteData.mapError ArticleHttpError
        |> RemoteData.andThen RemoteData.fromResult


buildFullArticleRequest : Article Preview -> Http.Request (ArticleResult Full)
buildFullArticleRequest article =
    Http.get (buildFullArticleUrl article) articleResponseDecoder


buildFullArticleUrl : Article Preview -> Url
buildFullArticleUrl article =
    let
        queryParams =
            [ KeyValue ( "action", "query" )
            , KeyValue ( "format", "json" )
            , KeyValue ( "generator", "links" )
            , KeyValue ( "prop", "revisions" )
            , KeyValue ( "rvprop", "content" )
            , KeyValue ( "origin", "*" )
            , KeyValue ( "formatversion", "2" )
            , KeyValue ( "plnamespace", "0" )
            , KeyValue ( "gpllimit", "max" )
            , KeyValue ( "redirects", "1" )
            , KeyValue ( "pageids", id article )
            ]
    in
        Url.build "https://en.wikipedia.org/w/api.php" queryParams



-- API (PREVIEW)


type alias RemoteArticlePair =
    RemoteData ArticlePairError ( Article Preview, Article Preview )


type ArticlePairError
    = UnexpectedArticleCount
    | PreviewArticleHttpError Http.Error


getRandomPair : (RemoteArticlePair -> msg) -> Cmd msg
getRandomPair toMsg =
    buildRandomTitleRequest 2
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteArticlePair >> toMsg)


toRemoteArticlePair : WebData (List (Article Preview)) -> RemoteArticlePair
toRemoteArticlePair remoteTitles =
    remoteTitles
        |> RemoteData.mapError PreviewArticleHttpError
        |> RemoteData.andThen toPair


toPair : List (Article Preview) -> RemoteArticlePair
toPair titles =
    case titles of
        first :: second :: _ ->
            RemoteData.succeed ( first, second )

        _ ->
            RemoteData.Failure UnexpectedArticleCount


buildRandomTitleRequest : Int -> Http.Request (List (Article Preview))
buildRandomTitleRequest titleCount =
    Http.get (buildRandomTitlesUrl titleCount) previewResponseDecoder


buildRandomTitlesUrl : Int -> Url
buildRandomTitlesUrl titleCount =
    let
        articleNamespace =
            "0"

        queryParams =
            [ KeyValue ( "action", "query" )
            , KeyValue ( "format", "json" )
            , KeyValue ( "list", "random" )
            , KeyValue ( "rnlimit", toString titleCount )
            , KeyValue ( "rnnamespace", articleNamespace )
            , KeyValue ( "origin", "*" )
            ]
    in
        Url.build "https://en.wikipedia.org/w/api.php" queryParams



-- SERIALIZATION (FULL)


articleResponseDecoder : Decoder (ArticleResult Full)
articleResponseDecoder =
    oneOf
        [ map Ok successDecoder
        , map Err errorDecoder
        ]


successDecoder : Decoder (Article Full)
successDecoder =
    at [ "query", "pages" ] fullDecoder


previewDecoder : Decoder (Article Preview)
previewDecoder =
    succeed Article
        |> required "title" string


fullDecoder : Decoder (Article Full)
fullDecoder =
    decode Article
        |> required "pageid" Id.decoder
        |> required "title" string
        |> required "links" (list previewDecoder)
        |> required "revisions" revisionsDecoder


metadataDecoder : Decoder Metadata
metadataDecoder =
    decode Metadata
        |> required "title" string
        |> required "ns" namespaceDecoder


namespaceDecoder : Decoder Namespace
namespaceDecoder =
    let
        toNamespace namespaceId =
            if namespaceId == 0 then
                ArticleNamespace
            else
                NonArticleNamespace
    in
        map toNamespace int


errorDecoder : Decoder ArticleError
errorDecoder =
    let
        toError errorCode =
            case errorCode of
                "missingtitle" ->
                    ArticleNotFound

                "invalidtitle" ->
                    InvalidTitle

                _ ->
                    UnknownError errorCode

        errorCode =
            at [ "error", "code" ] string
    in
        map toError errorCode



-- SERIALIZATION (PREVIEW)


previewResponseDecoder : Decoder (List (Article Preview))
previewResponseDecoder =
    at
        [ "query", "random" ]
        (list <| previewDecoder)
