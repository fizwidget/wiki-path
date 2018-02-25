module Messages exposing (Message(..))

import RemoteData exposing (WebData)
import Model exposing (Article)


type Message
    = SourceArticleTitleChange String
    | DestinationArticleTitleChange String
    | FetchArticlesRequest
    | FetchSourceArticleResult (WebData (Maybe Article))
    | FetchDestinationArticleResult (WebData (Maybe Article))
