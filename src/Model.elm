module Model exposing (Model, Article, initialModel)

import RemoteData exposing (WebData)


type alias Model =
    { title : String
    , article : WebData Article
    }


type alias Article =
    { title : String
    , content : String
    }


initialModel : Model
initialModel =
    { title = ""
    , article = RemoteData.NotAsked
    }
