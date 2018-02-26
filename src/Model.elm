module Model exposing (Model, RemoteArticle, Article, Error(..), initialModel)

import Http
import RemoteData exposing (RemoteData)


type Error
    = HttpError Http.Error
    | ArticleNotFound
    | UnknownError String


type alias RemoteArticle =
    RemoteData Error Article


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
