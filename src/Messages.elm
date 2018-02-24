module Messages exposing (Message(..))

import RemoteData exposing (WebData)
import Model exposing (Article)


type Message
    = FetchArticleRequest
    | FetchArticleResult (WebData (Maybe Article))
    | ArticleTitleChange String
