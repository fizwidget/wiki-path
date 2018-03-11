module Setup.Types exposing (Msg(..), Model, Transition)

import Common.Types exposing (Article, RemoteArticle)


type Msg
    = SourceArticleTitleChange String
    | DestinationArticleTitleChange String
    | FetchArticlesRequest
    | FetchSourceArticleResult RemoteArticle
    | FetchDestinationArticleResult RemoteArticle


type alias Transition =
    { source : Article
    , destination : Article
    }


type alias Model =
    { sourceTitleInput : String
    , destinationTitleInput : String
    , sourceArticle : RemoteArticle
    , destinationArticle : RemoteArticle
    }
