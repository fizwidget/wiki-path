module View.Spinner exposing (view)

import Css exposing (..)
import Html.Styled exposing (Html, div)
import Html.Styled.Attributes exposing (class)


view : Html msg
view =
    div
        -- Spinner styles live in top-level CSS file
        [ class "lds-ellipsis" ]
        (List.repeat 4 emptyDiv)


emptyDiv : Html msg
emptyDiv =
    div [] []
