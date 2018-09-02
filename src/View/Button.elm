module View.Button exposing (Option(..), view)

import Html.Styled exposing (Attribute, Html, button, text)
import Html.Styled.Attributes exposing (class, disabled, type_)
import Html.Styled.Events exposing (onClick)


type Option msg
    = OnClick msg
    | Primary
    | Secondary
    | Large
    | Disabled Bool


view : String -> List (Option msg) -> Html msg
view title options =
    button
        (defaultAttributes ++ List.concatMap toAttributes options)
        [ text title ]


defaultAttributes : List (Attribute msg)
defaultAttributes =
    [ type_ "button", class "btn" ]


toAttributes : Option msg -> List (Attribute msg)
toAttributes option =
    case option of
        OnClick msg ->
            [ onClick msg ]

        Primary ->
            [ class "btn-primary", type_ "submit" ]

        Secondary ->
            [ class "btn-link" ]

        Large ->
            [ class "btn-lg" ]

        Disabled isDisabled ->
            [ disabled isDisabled ]
