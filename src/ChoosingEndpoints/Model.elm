module ChoosingEndpoints.Model exposing (ChoosingEndpointsModel, initialChoosingEndpointsModel)

import RemoteData exposing (RemoteData)
import Common.Model exposing (Article, RemoteArticle)


initialChoosingEndpointsModel : ChoosingEndpointsModel
initialChoosingEndpointsModel =
    { sourceTitleInput = ""
    , destinationTitleInput = ""
    , sourceArticle = RemoteData.NotAsked
    , destinationArticle = RemoteData.NotAsked
    }


type alias ChoosingEndpointsModel =
    { sourceTitleInput : String
    , destinationTitleInput : String
    , sourceArticle : RemoteArticle
    , destinationArticle : RemoteArticle
    }
