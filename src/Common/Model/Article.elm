module Common.Model.Article exposing (Article, ArticleResult, RemoteArticle, ArticleError(..))

import Http
import RemoteData exposing (RemoteData)
import Common.Model.Title exposing (Title)


type alias HtmlString =
    String


type alias Article =
    { title : Title
    , links : List Title
    , content : HtmlString
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
