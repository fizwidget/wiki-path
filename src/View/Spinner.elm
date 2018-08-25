module View.Spinner exposing (view)

import Html.Styled exposing (Html, div)
import Html.Styled.Attributes exposing (css, class)
import Css exposing (..)


view : { isVisible : Bool } -> Html msg
view { isVisible } =
    div
        [ class "lds-ellipsis" -- Styles live in top-level CSS file
        , css [ visibilityStyle isVisible ]
        ]
        (List.repeat 4 emptyDiv)


visibilityStyle : Bool -> Style
visibilityStyle isVisible =
    if isVisible then
        visibility visible
    else
        visibility hidden


emptyDiv : Html msg
emptyDiv =
    div [] []
