module Model exposing (Model, Article, initialModel)

import RemoteData exposing (WebData)


type alias Article =
    String


type alias Model =
    { articleUrl : String
    , articleContent : WebData Article
    }


initialModel : Model
initialModel =
    Model "" RemoteData.Loading
