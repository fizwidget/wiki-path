module View.Input exposing (Option(..), text)

import Html.Styled exposing (Attribute, Html, div, input)
import Html.Styled.Attributes exposing (class, disabled, placeholder, type_, value)
import Html.Styled.Events exposing (onInput)


type Option msg
    = Large
    | OnInput (String -> msg)
    | Value String
    | Placeholder String
    | Disabled Bool


text : List (Option msg) -> Html msg
text options =
    div (List.concatMap toContainerAttribute options)
        [ input (defaultAttributes ++ List.concatMap toInputAttribute options) [] ]


defaultAttributes : List (Attribute msg)
defaultAttributes =
    [ type_ "text", class "form-control" ]


toContainerAttribute : Option msg -> List (Attribute msg)
toContainerAttribute option =
    case option of
        Large ->
            [ class "input-group-lg" ]

        OnInput toMsg ->
            []

        Value textValue ->
            []

        Placeholder textValue ->
            []

        Disabled isDisabled ->
            []


toInputAttribute : Option msg -> List (Attribute msg)
toInputAttribute option =
    case option of
        Large ->
            []

        OnInput toMsg ->
            [ onInput toMsg ]

        Value textValue ->
            [ value textValue ]

        Placeholder textValue ->
            [ placeholder textValue ]

        Disabled isDisabled ->
            [ disabled isDisabled ]
