module Common.Error exposing (view)

import Css exposing (textAlign, center, fontSize, px)
import Html.Styled exposing (Html, div, pre, text)
import Html.Styled.Attributes exposing (css)


view : String -> String -> Html msg
view generalDescription serverErrorText =
    div [ css [ textAlign center ] ]
        [ text generalDescription
        , pre
            [ css [ fontSize (px 16) ] ]
            [ text <| "(" ++ serverErrorText ++ ")" ]
        ]
