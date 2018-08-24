module View.Spinner exposing (view)

import Html.Styled exposing (Html, div)
import Html.Styled.Attributes exposing (css, class)
import Css exposing (..)


view : { isVisible : Bool } -> Html msg
view { isVisible } =
    let
        visibilityValue =
            if isVisible then
                visibility visible
            else
                visibility hidden
    in
        div
            [ class "lds-ellipsis", css [ visibilityValue ] ]
            (List.repeat 4 <| div [] [])
