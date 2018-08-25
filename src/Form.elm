module Form exposing (group)

import Html.Styled exposing (Html, fromUnstyled, toUnstyled)
import Bootstrap.Form


group : Html msg -> Html msg -> Html msg
group content invalidFeedback =
    fromUnstyled <|
        Bootstrap.Form.group []
            [ toUnstyled content
            , Bootstrap.Form.invalidFeedback [] [ toUnstyled invalidFeedback ]
            ]
