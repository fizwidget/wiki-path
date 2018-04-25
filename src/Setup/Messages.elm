module Setup.Messages exposing (SetupMsg(..))

import Common.Article.Model exposing (RemoteArticle)


type SetupMsg
    = SourceArticleTitleChange String
    | DestinationArticleTitleChange String
    | FetchArticlesRequest
    | FetchSourceArticleResult RemoteArticle
    | FetchDestinationArticleResult RemoteArticle
