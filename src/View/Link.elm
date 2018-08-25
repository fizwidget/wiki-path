module View.Link exposing (view)

import Html.Styled exposing (Html, a, text)
import Html.Styled.Attributes exposing (href)
import Data.Title as Title exposing (Title)


view : Title -> Html msg
view title =
    a
        [ href (toUrl title) ]
        [ text (Title.asString title) ]


toUrl : Title -> String
toUrl title =
    "https://en.wikipedia.org/wiki/" ++ (Title.asString title)
