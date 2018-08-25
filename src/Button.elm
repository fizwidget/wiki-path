module Button exposing (view, Option(..))

import Html.Styled exposing (Html, text, fromUnstyled, toUnstyled)
import Bootstrap.Button


type Option msg
    = OnClick msg
    | Primary
    | Secondary
    | Light
    | Large
    | Disabled Bool


view : String -> List (Option msg) -> Html msg
view title options =
    let
        button =
            Bootstrap.Button.button
                (List.map toBootstrapOption options)
                [ text title |> toUnstyled ]
    in
        fromUnstyled button


toBootstrapOption : Option msg -> Bootstrap.Button.Option msg
toBootstrapOption option =
    case option of
        OnClick msg ->
            Bootstrap.Button.onClick msg

        Primary ->
            Bootstrap.Button.primary

        Secondary ->
            Bootstrap.Button.secondary

        Light ->
            Bootstrap.Button.light

        Large ->
            Bootstrap.Button.large

        Disabled isDisabled ->
            Bootstrap.Button.disabled isDisabled
