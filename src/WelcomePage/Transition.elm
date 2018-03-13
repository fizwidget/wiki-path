module WelcomePage.Transition exposing (transition)

import RemoteData
import Common.Model exposing (Article)
import WelcomePage.Model


type alias Transition =
    { source : Article
    , destination : Article
    }


transition : WelcomePage.Model.Model -> Maybe Transition
transition { sourceArticle, destinationArticle } =
    RemoteData.map2 Transition sourceArticle destinationArticle
        |> RemoteData.toMaybe
