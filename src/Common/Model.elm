module Common.Model exposing (Title(..), Article, ArticleResult, RemoteArticle, ArticleError(..), getTitle)

import Http
import HtmlParser exposing (Node)
import RemoteData exposing (RemoteData)


type Title
    = Title String


getTitle : Article -> String
getTitle article =
    case article.title of
        Title title ->
            title


type alias Article =
    { title : Title
    , content : List Node
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
