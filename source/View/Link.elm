module View.Link exposing (view)

import Data.Title as Title exposing (Title)
import Html.Styled exposing (Html, a, text)
import Html.Styled.Attributes exposing (href)


view : Title -> Html msg
view title =
    a
        [ href (toUrl title) ]
        [ text (Title.value title) ]


toUrl : Title -> String
toUrl title =
    "https://en.wikipedia.org/wiki/" ++ (Title.value title)
