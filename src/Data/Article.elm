module Data.Article exposing (Article, Link, Namespace(..))

import Data.Title as Title exposing (Title)


type alias Article =
    { title : Title
    , links : List Link
    , content : HtmlString
    }


type alias Link =
    { title : Title
    , namespace : Namespace
    , exists : Bool
    }


type Namespace
    = ArticleNamespace
    | NonArticleNamespace


type alias HtmlString =
    String
