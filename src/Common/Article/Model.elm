module Common.Article.Model
    exposing
        ( Article
        , Link
        , Namespace(..)
        , ArticleResult
        , RemoteArticle
        , ArticleError(..)
        )

import Http
import RemoteData exposing (RemoteData)
import Common.Title.Model exposing (Title)


type alias Article =
    { title : Title
    , links : List Link
    , content : HtmlString
    }


type alias Link =
    { title : Title
    , namespace : Namespace
    , doesExist : Bool
    }


type Namespace
    = ArticleNamespace
    | NonArticleNamespace


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
    | HttpError Http.Error
