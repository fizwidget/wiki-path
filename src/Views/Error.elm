module Views.Error exposing (genericError, articleError)

import Html.Styled exposing (Html, div, pre, text)
import Html.Styled.Attributes exposing (css)
import Css exposing (textAlign, center, fontSize, px)
import Data.Article exposing (ArticleError(..))


genericError : String -> String -> Html msg
genericError generalDescription serverErrorText =
    div [ css [ textAlign center ] ]
        [ text generalDescription
        , pre
            [ css [ fontSize (px 16) ] ]
            [ text <| "(" ++ serverErrorText ++ ")" ]
        ]


articleError : ArticleError -> Html msg
articleError error =
    let
        errorView =
            case error of
                ArticleNotFound ->
                    text "Couldn't find that article :("

                InvalidTitle ->
                    text "Not a valid article title :("

                UnknownError errorCode ->
                    genericError "Unknown error \x1F92F" errorCode

                HttpError error ->
                    genericError "Network error 😭" (toString error)
    in
        div [] [ errorView ]
