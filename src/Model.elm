module Model exposing (Model, RemoteArticle, Article, ArticleResult, ApiError(..), initialModel)

import RemoteData exposing (WebData)


type ApiError
    = ArticleNotFound
    | UnknownError String


type alias ArticleResult =
    Result ApiError Article


type alias RemoteArticle =
    WebData ArticleResult


type alias Model =
    { sourceTitleInput : String
    , destinationTitleInput : String
    , sourceArticle : RemoteArticle
    , destinationArticle : RemoteArticle
    }


type alias Article =
    { title : String
    , content : String
    }


initialModel : Model
initialModel =
    { sourceTitleInput = ""
    , destinationTitleInput = ""
    , sourceArticle = RemoteData.NotAsked
    , destinationArticle = RemoteData.NotAsked
    }
