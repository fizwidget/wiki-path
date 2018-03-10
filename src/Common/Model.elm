module Common.Model exposing (Article, RemoteArticle, ArticleError(..))

import Http
import HtmlParser exposing (Node)
import RemoteData exposing (RemoteData)


type alias Article =
    { title : String
    , content : List Node
    }


type alias RemoteArticle =
    RemoteData ArticleError Article


type ArticleError
    = ArticleNotFound
    | UnknownError String
    | NetworkError Http.Error
