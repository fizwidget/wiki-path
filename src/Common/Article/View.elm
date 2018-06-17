module Common.Article.View exposing (viewError)

import Html.Styled exposing (Html, div, text)
import Common.Article.Model exposing (ArticleError(..))
import Common.Error.View as Error


viewError : ArticleError -> Html msg
viewError error =
    let
        errorView =
            case error of
                ArticleNotFound ->
                    text "Couldn't find that article :("

                InvalidTitle ->
                    text "Not a valid article title :("

                UnknownError errorCode ->
                    Error.view "Unknown error \x1F92F" errorCode

                HttpError error ->
                    Error.view "Network error 😭" (toString error)
    in
        div [] [ errorView ]
