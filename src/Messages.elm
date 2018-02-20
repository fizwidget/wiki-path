module Messages exposing (Message(..))

import RemoteData exposing (WebData)
import Model exposing (Article, Url)


type Message
    = FetchArticleRequest
    | FetchArticleResult (WebData Article)
    | ArticleUrlChange Url
