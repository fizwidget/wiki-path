module Setup.Fetch exposing (article, randomTitlePair)

import RemoteData exposing (WebData)
import Common.Article.Model exposing (ArticleResult, RemoteArticle, ArticleError(HttpError))
import Common.Article.Api as ArticleApi
import Common.Title.Model exposing (Title, RemoteTitlePair, TitleError(HttpError, UnexpectedTitleCount))
import Common.Title.Api as TitleApi


article : (RemoteArticle -> msg) -> String -> Cmd msg
article toMsg title =
    ArticleApi.buildRequest title
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteArticle >> toMsg)


randomTitlePair : (RemoteTitlePair -> msg) -> Cmd msg
randomTitlePair toMsg =
    TitleApi.buildRandomTitleRequest 2
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteTitlePair >> toMsg)


toRemoteArticle : WebData ArticleResult -> RemoteArticle
toRemoteArticle webData =
    webData
        |> RemoteData.mapError Common.Article.Model.HttpError
        |> RemoteData.andThen RemoteData.fromResult


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
