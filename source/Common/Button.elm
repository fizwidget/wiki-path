module Common.Button exposing (view)

import Bootstrap.Button as BootstrapButton
import Html.Styled exposing (Html, fromUnstyled, toUnstyled)


view : List (BootstrapButton.Option msg) -> List (Html msg) -> Html msg
view options children =
    BootstrapButton.button options (List.map toUnstyled children)
        |> fromUnstyled
