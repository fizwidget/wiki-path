module Messages exposing (Message(..))

import Model.Main exposing (RemoteArticle)


type Message
    = SourceArticleTitleChange String
    | DestinationArticleTitleChange String
    | FetchArticlesRequest
    | FetchSourceArticleResult RemoteArticle
    | FetchDestinationArticleResult RemoteArticle
