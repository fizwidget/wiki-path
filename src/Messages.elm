module Messages exposing (Message(..))

import RemoteData exposing (WebData)
import Model exposing (Article)


type Message
    = OnFetchArticle (WebData Article)
