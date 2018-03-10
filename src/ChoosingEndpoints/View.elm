module ChoosingEndpoints.View exposing (choosingEndpointsView)

import Html exposing (Html, div)
import Messages exposing (Msg)
import ChoosingEndpoints.View.Inputs exposing (titleInputs, loadArticlesButton)
import ChoosingEndpoints.View.Content exposing (articlesContent)
import ChoosingEndpoints.Model exposing (ChoosingEndpointsModel)


choosingEndpointsView : ChoosingEndpointsModel -> Html Msg
choosingEndpointsView model =
    div []
        [ titleInputs model
        , loadArticlesButton
        , articlesContent model.sourceArticle model.destinationArticle
        ]
