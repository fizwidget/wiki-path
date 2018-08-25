module View.ArticleError exposing (view)

import Html.Styled exposing (Html, div, text)
import Request.Article exposing (ArticleError(..))


view : ArticleError -> Html msg
view error =
    div [] [ text (toErrorMessage error) ]


toErrorMessage : ArticleError -> String
toErrorMessage error =
    case error of
        ArticleNotFound ->
            "Couldn't find that article :("

        InvalidTitle ->
            "Not a valid article title :("

        UnknownError _ ->
            "Unknown error \x1F92F"

        HttpError _ ->
            "Network error 😭"
