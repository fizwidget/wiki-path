module View.Error exposing (viewGeneralError, viewArticleError)

import Html.Styled exposing (Html, div, pre, text)
import Html.Styled.Attributes exposing (css)
import Css exposing (textAlign, center, fontSize, px)
import Data.Article
    exposing
        ( ArticleError
            ( ArticleNotFound
            , InvalidTitle
            , UnknownError
            , HttpError
            )
        )


viewGeneralError : String -> String -> Html msg
viewGeneralError generalDescription serverErrorText =
    div [ css [ textAlign center ] ]
        [ text generalDescription
        , pre
            [ css [ fontSize (px 16) ] ]
            [ text <| "(" ++ serverErrorText ++ ")" ]
        ]


viewArticleError : ArticleError -> Html msg
viewArticleError error =
    let
        errorView =
            case error of
                ArticleNotFound ->
                    text "Couldn't find that article :("

                InvalidTitle ->
                    text "Not a valid article title :("

                UnknownError errorCode ->
                    viewGeneralError "Unknown error \x1F92F" errorCode

                HttpError error ->
                    viewGeneralError "Network error 😭" (toString error)
    in
        div [] [ errorView ]
