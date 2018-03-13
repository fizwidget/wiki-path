module Setup.Messages exposing (Msg(..))

import Common.Model exposing (RemoteArticle)


type Msg
    = SourceArticleTitleChange String
    | DestinationArticleTitleChange String
    | FetchArticlesRequest
    | FetchSourceArticleResult RemoteArticle
    | FetchDestinationArticleResult RemoteArticle
