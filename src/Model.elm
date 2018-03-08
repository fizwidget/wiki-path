module Model exposing (Model, RemoteArticle, Article, ArticleError(..), initialModel)

import Http
import HtmlParser exposing (Node)
import RemoteData exposing (RemoteData)


initialModel : Model
initialModel =
    { sourceTitleInput = ""
    , destinationTitleInput = ""
    , sourceArticle = RemoteData.NotAsked
    , destinationArticle = RemoteData.NotAsked
    }


type alias Model =
    { sourceTitleInput : String
    , destinationTitleInput : String
    , sourceArticle : RemoteArticle
    , destinationArticle : RemoteArticle
    }


type alias RemoteArticle =
    RemoteData ArticleError Article


type ArticleError
    = ArticleNotFound
    | UnknownError String
    | NetworkError Http.Error


type alias Article =
    { title : String
    , content : List Node
    }
