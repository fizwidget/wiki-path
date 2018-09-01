module Input exposing (Option(..), text)

import Html.Styled exposing (Attribute, Html, div, input)
import Html.Styled.Attributes exposing (class, disabled, placeholder, type_, value)
import Html.Styled.Events exposing (onInput)


type Option msg
    = Large
    | OnInput (String -> msg)
    | Value String
    | Placeholder String
    | Disabled Bool
    | Error Bool


text : List (Option msg) -> Html msg
text options =
    div (List.filterMap errorAttribute options)
        [ input (defaultAttributes ++ List.map toAttribute options) [] ]


defaultAttributes : List (Attribute msg)
defaultAttributes =
    [ type_ "text", class "form-control" ]


toAttribute : Option msg -> Attribute msg
toAttribute option =
    case option of
        Large ->
            class "btn-lg"

        OnInput toMsg ->
            onInput toMsg

        Value textValue ->
            value textValue

        Placeholder textValue ->
            placeholder textValue

        Disabled isDisabled ->
            disabled isDisabled

        Error isError ->
            class ""


errorAttribute : Option msg -> Maybe (Attribute msg)
errorAttribute option =
    case option of
        Error True ->
            -- Not working!
            Just (class "has-error")

        _ ->
            Nothing
