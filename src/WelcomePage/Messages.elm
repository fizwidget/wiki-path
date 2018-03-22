module WelcomePage.Messages exposing (Msg(..))

import Common.Model exposing (RemoteArticle)


type Msg
    = StartArticleTitleChange String
    | EndArticleTitleChange String
    | FetchArticlesRequest
    | FetchStartArticleResult RemoteArticle
    | FetchEndArticleResult RemoteArticle
