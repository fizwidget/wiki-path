module Model exposing (Model, RemoteArticle, Article, ArticleResult, ApiError(..), initialModel)

import HtmlParser exposing (Node)
import RemoteData exposing (WebData)


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
    WebData ArticleResult


type alias ArticleResult =
    Result ApiError Article


type ApiError
    = ArticleNotFound
    | UnknownError String


type alias Article =
    { title : String
    , content : List Node
    }
