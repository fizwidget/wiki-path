module PathfindingPage.Model exposing (Model, Error(..))

import Common.Model exposing (Title, Article, RemoteArticle, ArticleError)


type alias Model =
    { start : Article
    , end : Article
    , stops : List Title
    , error : Maybe Error
    }


type Error
    = PathNotFound
    | ArticleError ArticleError
