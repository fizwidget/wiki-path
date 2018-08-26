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
        , getFullArticle
        , getRemoteArticle
        , viewError
        )

import Http
import RemoteData exposing (RemoteData, WebData)
import Json.Decode exposing (Decoder, field, at, map, bool, string, int, list, oneOf)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Url exposing (Url, QueryParam(KeyValue, Key))
import Html.Styled exposing (Html, div, text, a)
import Html.Styled.Attributes exposing (href)


type Article a
    = Article Title a


type alias Title =
    String


type Preview
    = Preview Namespace


type Full
    = Full Content


type alias Content =
    { links : List (Article Preview)
    , body : HtmlString
    }


type Namespace
    = ArticleNamespace
    | NonArticleNamespace


type alias HtmlString =
    String


title : Article a -> String
title (Article title _) =
    title


body : Article Full -> HtmlString
body (Article _ (Full { body })) =
    body


equals : Article a -> Article b -> Bool
equals first second =
    title first == title second


asPreview : Article Full -> Article Preview
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

        FullArticleHttpError _ ->
            "Network error 😭"



-- API (FULL)


type alias ArticleResult =
    Result ArticleError (Article Full)


type alias RemoteArticle =
    RemoteData ArticleError (Article Full)


type ArticleError
    = ArticleNotFound
    | InvalidTitle
    | UnknownError String
    | FullArticleHttpError Http.Error


getFullArticle : (ArticleResult -> msg) -> Article Preview -> Cmd msg
getFullArticle toMsg article =
    article
        |> buildRequest
        |> Http.send (toArticleResult >> toMsg)


toArticleResult : Result Http.Error ArticleResult -> ArticleResult
toArticleResult result =
    result
        |> Result.mapError FullArticleHttpError
        |> Result.andThen identity


getRemoteArticle : (RemoteArticle -> msg) -> Article Preview -> Cmd msg
getRemoteArticle toMsg article =
    article
        |> buildRequest
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteArticle >> toMsg)


toRemoteArticle : WebData ArticleResult -> RemoteArticle
toRemoteArticle webData =
    webData
        |> RemoteData.mapError FullArticleHttpError
        |> RemoteData.andThen RemoteData.fromResult


buildRequest : Article Preview -> Http.Request ArticleResult
buildRequest article =
    Http.get (buildArticleUrl article) articleResponseDecoder


buildArticleUrl : Article Preview -> Url
buildArticleUrl article =
    let
        queryParams =
            [ KeyValue ( "action", "parse" )
            , KeyValue ( "format", "json" )
            , KeyValue ( "formatversion", "2" )
            , KeyValue ( "origin", "*" )
            , KeyValue ( "page", title article )
            , Key "redirects"
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


articleResponseDecoder : Decoder ArticleResult
articleResponseDecoder =
    oneOf
        [ map Ok successDecoder
        , map Err errorDecoder
        ]


successDecoder : Decoder Article
successDecoder =
    field "parse" fullDecoder


previewDecoder : Decoder (Article Preview)
previewDecoder =
    succeed Article
        |> required "title" string


fullDecoder : Decoder (Article Full)
fullDecoder =
    decode Article
        |> required "title" string
        |> required "links" (list previewDecoder)
        |> required "text" string


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
