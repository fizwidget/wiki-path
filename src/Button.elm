module Button exposing (view)

import Html.Styled exposing (Html, fromUnstyled, toUnstyled)
import Bootstrap.Button as BootstrapButton


view : List (BootstrapButton.Option msg) -> List (Html msg) -> Html msg
view options children =
    BootstrapButton.button options (List.map toUnstyled children)
        |> fromUnstyled
