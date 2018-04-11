module Welcome.Messages exposing (WelcomeMsg(..))

import Common.Model.Article exposing (RemoteArticle)


type WelcomeMsg
    = SourceArticleTitleChange String
    | DestinationArticleTitleChange String
    | FetchArticlesRequest
    | FetchSourceArticleResult RemoteArticle
    | FetchDestinationArticleResult RemoteArticle
