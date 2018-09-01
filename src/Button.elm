module Button exposing (Option(..), view)

import Html.Styled exposing (Attribute, Html, button, text)
import Html.Styled.Attributes exposing (class, disabled, type_)
import Html.Styled.Events exposing (onClick)


type Option msg
    = OnClick msg
    | Primary
    | Secondary
    | Light
    | Large
    | Disabled Bool


view : String -> List (Option msg) -> Html msg
view title options =
    button
        (defaultAttributes ++ List.map toAttribute options)
        [ text title ]


defaultAttributes : List (Attribute msg)
defaultAttributes =
    [ type_ "button", class "btn" ]


toAttribute : Option msg -> Attribute msg
toAttribute option =
    case option of
        OnClick msg ->
            onClick msg

        Primary ->
            class "btn-primary"

        Secondary ->
            class "btn-info"

        Light ->
            class "btn-link"

        Large ->
            class "btn-lg"

        Disabled isDisabled ->
            disabled isDisabled
