module Common.Model exposing (Title(..), Article, ArticleResult, RemoteArticle, ArticleError(..), getTitle, value)

import Http
import RemoteData exposing (RemoteData)


type Title
    = Title String


value : Title -> String
value (Title title) =
    title


getTitle : Article -> String
getTitle article =
    value article.title


type alias Article =
    { title : Title
    , links : List Title
    , content : String
    }


type alias ArticleResult =
    Result ArticleError Article


type alias RemoteArticle =
    RemoteData ArticleError Article


type ArticleError
    = ArticleNotFound
    | InvalidTitle
    | UnknownError String
    | NetworkError Http.Error
