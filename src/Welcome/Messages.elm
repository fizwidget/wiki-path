module Welcome.Messages exposing (WelcomeMsg(..))

import Common.Model.Article exposing (RemoteArticle)


type WelcomeMsg
    = StartArticleTitleChange String
    | EndArticleTitleChange String
    | FetchArticlesRequest
    | FetchStartArticleResult RemoteArticle
    | FetchEndArticleResult RemoteArticle
