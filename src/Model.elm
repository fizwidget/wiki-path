module Model exposing (Model, Url, Article, initialModel)

import RemoteData exposing (WebData)


type alias Url =
    String


type alias Article =
    String


type alias Model =
    { articleUrl : Url
    , articleContent : WebData Article
    }


initialModel : Model
initialModel =
    Model "" RemoteData.NotAsked
