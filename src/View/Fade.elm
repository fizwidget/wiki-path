module View.Fade exposing (view)

import Css exposing (..)
import Html.Styled exposing (Html, div)
import Html.Styled.Attributes exposing (css)


view : Html msg -> Html msg
view content =
    div
        [ css
            [ position relative
            , after
                [ property "content" "''"
                , position absolute
                , top (px 0)
                , bottom (px 0)
                , left (px 0)
                , right (px 0)
                , backgroundImage
                    (linearGradient
                        (stop2 (rgba 255 255 255 0) (pct 60))
                        (stop2 (rgba 255 255 255 1) (pct 100))
                        []
                    )
                ]
            ]
        ]
        [ content ]
