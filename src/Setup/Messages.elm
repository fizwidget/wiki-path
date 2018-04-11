module Setup.Messages exposing (SetupMsg(..))

import Common.Model.Article exposing (RemoteArticle)


type SetupMsg
    = SourceArticleTitleChange String
    | DestinationArticleTitleChange String
    | FetchArticlesRequest
    | FetchSourceArticleResult RemoteArticle
    | FetchDestinationArticleResult RemoteArticle
