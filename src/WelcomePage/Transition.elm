module WelcomePage.Transition exposing (transition)

import RemoteData
import Common.Model exposing (Article)
import WelcomePage.Model exposing (Model)


type alias Transition =
    { start : Article
    , end : Article
    }


transition : Model -> Maybe Transition
transition { startArticle, endArticle } =
    RemoteData.map2 Transition startArticle endArticle
        |> RemoteData.toMaybe
