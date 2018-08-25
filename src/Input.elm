module Input exposing (text, Option(..))

import Html.Styled exposing (Html, fromUnstyled)
import Bootstrap.Form.Input


type Option msg
    = Large
    | OnInput (String -> msg)
    | Value String
    | Placeholder String
    | Disabled Bool
    | Error Bool


text : List (Option msg) -> Html msg
text options =
    Bootstrap.Form.Input.text (List.filterMap toBootstrapOption options)
        |> fromUnstyled


toBootstrapOption : Option msg -> Maybe (Bootstrap.Form.Input.Option msg)
toBootstrapOption option =
    case option of
        Large ->
            Just Bootstrap.Form.Input.large

        OnInput toMsg ->
            Just (Bootstrap.Form.Input.onInput toMsg)

        Value value ->
            Just (Bootstrap.Form.Input.value value)

        Placeholder placeholder ->
            Just (Bootstrap.Form.Input.placeholder placeholder)

        Disabled isDisabled ->
            Just (Bootstrap.Form.Input.disabled isDisabled)

        Error isError ->
            if isError then
                Just Bootstrap.Form.Input.danger
            else
                Nothing
