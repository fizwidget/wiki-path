module Common.Model exposing (Title(..), Article, ArticleResult, RemoteArticle, ArticleError(..), getTitle, stringValue)

import Http
import RemoteData exposing (RemoteData)


type Title
    = Title String


stringValue : Title -> String
stringValue (Title title) =
    title


getTitle : Article -> String
getTitle article =
    case article.title of
        Title title ->
            title


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
