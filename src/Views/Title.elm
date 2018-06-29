module Views.Title exposing (viewAsLink)

import Html.Styled exposing (Html, text, a)
import Html.Styled.Attributes exposing (href)
import Data.Title as Title exposing (Title)


viewAsLink : Title -> Html msg
viewAsLink title =
    a
        [ href (toUrl title) ]
        [ text (Title.value title) ]


toUrl : Title -> String
toUrl title =
    "https://en.wikipedia.org/wiki/" ++ (Title.value title)
