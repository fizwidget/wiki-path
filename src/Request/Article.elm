module Request.Article exposing (articleResult, remoteArticle)

import Http
import RemoteData exposing (WebData)
import Json.Decode exposing (Decoder, map, oneOf, field, at)
import Data.Url as Url exposing (Url, QueryParam(KeyValue, Key))
import Data.Article as Article exposing (ArticleResult, RemoteArticle, ArticleError(HttpError))


articleResult : (ArticleResult -> msg) -> String -> Cmd msg
articleResult toMsg title =
    buildRequest title
        |> Http.send (toArticleResult >> toMsg)


remoteArticle : (RemoteArticle -> msg) -> String -> Cmd msg
remoteArticle toMsg title =
    buildRequest title
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteArticle >> toMsg)



-- Internal


toArticleResult : Result Http.Error ArticleResult -> ArticleResult
toArticleResult result =
    result
        |> Result.mapError HttpError
        |> Result.andThen identity


toRemoteArticle : WebData ArticleResult -> RemoteArticle
toRemoteArticle webData =
    webData
        |> RemoteData.mapError HttpError
        |> RemoteData.andThen RemoteData.fromResult


buildRequest : String -> Http.Request ArticleResult
buildRequest title =
    Http.get (buildArticleUrl title) articleResponse


buildArticleUrl : String -> Url
buildArticleUrl title =
    let
        baseUrl =
            "https://en.wikipedia.org/w/api.php"

        queryParams =
            [ KeyValue ( "action", "parse" )
            , KeyValue ( "format", "json" )
            , KeyValue ( "formatversion", "2" )
            , KeyValue ( "origin", "*" )
            , KeyValue ( "page", title )
            , Key "redirects"
            ]
    in
        Url.build baseUrl queryParams



-- Serialisation


articleResponse : Decoder ArticleResult
articleResponse =
    oneOf
        [ map Ok <| field "parse" Article.decoder
        , map Err <| at [ "error", "code" ] Article.errorDecoder
        ]
