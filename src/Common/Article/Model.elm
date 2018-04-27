module Common.Article.Model exposing (Article, ArticleResult, RemoteArticle, ArticleError(..))

import Http
import RemoteData exposing (RemoteData)
import Common.Title.Model exposing (Title)


type alias Article =
    { title : Title
    , links : List Title
    , content : HtmlString
    }


type alias HtmlString =
    String


type alias ArticleResult =
    Result ArticleError Article


type alias RemoteArticle =
    RemoteData ArticleError Article


type ArticleError
    = ArticleNotFound
    | InvalidTitle
    | UnknownError String
    | NetworkError Http.Error
