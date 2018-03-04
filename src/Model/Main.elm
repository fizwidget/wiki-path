module Model.Main exposing (Model, RemoteArticle, ArticleResult, ApiError(..), initialModel)

import RemoteData exposing (WebData)
import Model.Article exposing (Article)


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
