module Common.Model exposing (Article, ArticleResult, RemoteArticle, ArticleError(..))

import Http
import HtmlParser exposing (Node)
import RemoteData exposing (RemoteData)


type alias Article =
    { title : String
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
