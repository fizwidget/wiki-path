module Common.View exposing (viewLink, viewSpinner, viewArticleError)

import Html exposing (Html, div, text, a)
import Html.Attributes exposing (href, class, style)
import Common.Model.Title exposing (Title, value)
import Common.Model.Article exposing (ArticleError(..))


viewArticleError : ArticleError -> Html msg
viewArticleError error =
    let
        errorMessage =
            case error of
                ArticleNotFound ->
                    "Couldn't find that article :("

                InvalidTitle ->
                    "Not a valid article title :("

                UnknownError errorCode ->
                    ("Unknown error: " ++ errorCode)

                NetworkError error ->
                    ("Network error: " ++ toString error)
    in
        text errorMessage


viewLink : Title -> Html msg
viewLink title =
    a [ href (toUrl title) ] [ text (value title) ]


toUrl : Title -> String
toUrl title =
    "https://en.wikipedia.org/wiki/" ++ (value title)


viewSpinner : Bool -> Html msg
viewSpinner isVisible =
    let
        visibility =
            if isVisible then
                "visible"
            else
                "hidden"
    in
        div
            [ class "lds-ellipsis", style [ ( "visibility", visibility ) ] ]
            [ div [] []
            , div [] []
            , div [] []
            , div [] []
            ]
