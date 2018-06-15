module Setup.Service exposing (requestArticle, requestRandomTitlePair)

import RemoteData exposing (WebData)
import Common.Article.Model exposing (ArticleResult, RemoteArticle, ArticleError(HttpError))
import Common.Article.Api as ArticleApi
import Common.Title.Model exposing (Title, RemoteTitlePair, TitleError(HttpError, UnexpectedTitleCount))
import Common.Title.Api as TitleApi


requestArticle : (RemoteArticle -> msg) -> String -> Cmd msg
requestArticle toMsg title =
    ArticleApi.buildRequest title
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteArticle >> toMsg)


toRemoteArticle : WebData ArticleResult -> RemoteArticle
toRemoteArticle webData =
    webData
        |> RemoteData.mapError Common.Article.Model.HttpError
        |> RemoteData.andThen RemoteData.fromResult


requestRandomTitlePair : (RemoteTitlePair -> msg) -> Cmd msg
requestRandomTitlePair toMsg =
    TitleApi.buildRandomTitleRequest 2
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteTitlePair >> toMsg)


toRemoteTitlePair : WebData (List Title) -> RemoteTitlePair
toRemoteTitlePair remoteTitles =
    let
        toPair titles =
            case titles of
                titleA :: titleB :: _ ->
                    RemoteData.succeed ( titleA, titleB )

                _ ->
                    RemoteData.Failure UnexpectedTitleCount
    in
        remoteTitles
            |> RemoteData.mapError Common.Title.Model.HttpError
            |> RemoteData.andThen toPair
