module Model exposing (Model(..), initialModel)

import Common.Model exposing (Article)
import ChoosingEndpoints.Model exposing (ChoosingEndpointsModel, initialChoosingEndpointsModel)


initialModel : Model
initialModel =
    ChoosingEndpoints initialChoosingEndpointsModel


type alias FindingRouteModel =
    { source : Article
    , destination : Article
    }


type alias Route =
    List Article


type alias FinishedRoutingModel =
    Result Route


type Model
    = ChoosingEndpoints ChoosingEndpointsModel
    | FindingRoute FindingRouteModel
    | FinishedRouting FinishedRoutingModel
