module Common.View exposing (viewLink)

import Html exposing (Html, text, a)
import Html.Attributes exposing (href)
import Common.Model.Title exposing (Title, value)


viewLink : Title -> Html msg
viewLink title =
    a [ href (toUrl title) ] [ text (value title) ]


toUrl : Title -> String
toUrl title =
    "https://en.wikipedia.org/wiki/" ++ (value title)
