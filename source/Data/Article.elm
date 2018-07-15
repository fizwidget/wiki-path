module Data.Article exposing (Article, Link, Namespace(ArticleNamespace, NonArticleNamespace))

import Data.Title as Title exposing (Title)


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
