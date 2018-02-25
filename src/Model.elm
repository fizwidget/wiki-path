module Model exposing (Model, Article, initialModel)

import RemoteData exposing (WebData)


type alias Model =
    { sourceTitleInput : String
    , destinationTitleInput : String
    , sourceArticle : WebData (Maybe Article)
    , destinationArticle : WebData (Maybe Article)
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
