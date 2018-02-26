module Messages exposing (Message(..))

import Model exposing (RemoteArticle)


type Message
    = SourceArticleTitleChange String
    | DestinationArticleTitleChange String
    | FetchArticlesRequest
    | FetchSourceArticleResult RemoteArticle
    | FetchDestinationArticleResult RemoteArticle
