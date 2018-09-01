module Form exposing (group)

import Html.Styled exposing (Html, div, span)


group : Html msg -> Html msg -> Html msg
group content invalidFeedback =
    div []
        [ content
        , span [] [ invalidFeedback ]
        ]
