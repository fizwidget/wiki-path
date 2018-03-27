module WelcomePage.Messages exposing (WelcomeMsg(..))

import Common.Model exposing (RemoteArticle)


type WelcomeMsg
    = StartArticleTitleChange String
    | EndArticleTitleChange String
    | FetchArticlesRequest
    | FetchStartArticleResult RemoteArticle
    | FetchEndArticleResult RemoteArticle
