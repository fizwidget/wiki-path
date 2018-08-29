module Article
    exposing
        ( Article
        , Preview
        , Full
        , Namespace(..)
        , ArticleResult
        , RemoteArticle
        , ArticleError(..)
        , RemoteTitlePair
        , title
        , content
        , links
        , asPreview
        , equals
        , getArticleResult
        , getRemoteArticle
        , getRandomPair
        , viewError
        , viewAsLink
        )

import Http
import RemoteData exposing (RemoteData, WebData)
import Json.Decode exposing (Decoder, field, at, map, bool, string, int, list, oneOf, succeed)
import Json.Decode.Pipeline exposing (decode, required, requiredAt, hardcoded, custom)
import Url exposing (Url, QueryParam(KeyValue, Key))
import Html.Styled exposing (Html, a, div, text)
import Html.Styled.Attributes exposing (href)


type Article a
    = Article String a


type Preview
    = Preview


type Full
    = Full Body


type alias Body =
    { content : HtmlString
    , links : List (Article Preview)
    }


type Namespace
    = ArticleNamespace
    | NonArticleNamespace


type alias HtmlString =
    String


title : Article a -> String
title (Article title _) =
    title


content : Article Full -> String
content (Article _ (Full { content })) =
    content


links : Article Full -> List (Article Preview)
links (Article _ (Full { links })) =
    links


asPreview : Article a -> Article Preview
asPreview (Article title _) =
    Article title Preview


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

        UnknownError _ ->
            "Unknown error \x1F92F"

        HttpError _ ->
            "Network error 😭"



-- API


type alias ArticleResult =
    Result ArticleError (Article Full)


type alias RemoteArticle =
    RemoteData ArticleError (Article Full)


type ArticleError
    = ArticleNotFound
    | InvalidTitle
    | UnknownError String
    | HttpError Http.Error


getArticleResult : (ArticleResult -> msg) -> String -> Cmd msg
getArticleResult toMsg title =
    title
        |> buildRequest
        |> Http.send (toArticleResult >> toMsg)


toArticleResult : Result Http.Error ArticleResult -> ArticleResult
toArticleResult result =
    result
        |> Result.mapError (Debug.log "### Error" >> HttpError)
        |> Result.andThen identity


getRemoteArticle : (RemoteArticle -> msg) -> String -> Cmd msg
getRemoteArticle toMsg title =
    title
        |> buildRequest
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteArticle >> toMsg)


toRemoteArticle : WebData ArticleResult -> RemoteArticle
toRemoteArticle webData =
    webData
        |> RemoteData.mapError HttpError
        |> RemoteData.andThen RemoteData.fromResult


buildRequest : String -> Http.Request ArticleResult
buildRequest title =
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



-- SERIALIZATION


responseDecoder : Decoder ArticleResult
responseDecoder =
    oneOf
        [ map Ok successDecoder
        , map Err errorDecoder -- handle pages with "missing" or "invalid" attributes
        ]


successDecoder : Decoder (Article Full)
successDecoder =
    at [ "query", "pages", "0" ] articleDecoder


articleDecoder : Decoder (Article Full)
articleDecoder =
    succeed Article
        |> required "title" string
        |> custom (map Full bodyDecoder)


bodyDecoder : Decoder Body
bodyDecoder =
    decode Body
        |> requiredAt [ "revisions", "0", "slots", "main", "content" ] string
        |> required "links" (list previewDecoder)


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



-- PREVIEW


type alias RemoteTitlePair =
    RemoteData TitleError ( Article Preview, Article Preview )


type TitleError
    = UnexpectedTitleCount
    | PreviewHttpError Http.Error


getRandomPair : (RemoteTitlePair -> msg) -> Cmd msg
getRandomPair toMsg =
    buildRandomTitleRequest 2
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteTitlePair >> toMsg)


toRemoteTitlePair : WebData (List (Article Preview)) -> RemoteTitlePair
toRemoteTitlePair remoteTitles =
    remoteTitles
        |> RemoteData.mapError PreviewHttpError
        |> RemoteData.andThen toPair


toPair : List (Article Preview) -> RemoteTitlePair
toPair titles =
    case titles of
        first :: second :: _ ->
            RemoteData.succeed ( first, second )

        _ ->
            RemoteData.Failure UnexpectedTitleCount


buildRandomTitleRequest : Int -> Http.Request (List (Article Preview))
buildRandomTitleRequest titleCount =
    Http.get (buildRandomTitlesUrl titleCount) randomTitlesResponseDecoder


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



-- SERIALIZATION


randomTitlesResponseDecoder : Decoder (List (Article Preview))
randomTitlesResponseDecoder =
    at
        [ "query", "random" ]
        (list previewDecoder)


previewDecoder : Decoder (Article Preview)
previewDecoder =
    succeed Article
        |> required "title" string
        |> hardcoded Preview
