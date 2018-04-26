module Common.View exposing (viewLink, viewSpinner, viewArticleError)

import Css exposing (..)
import Html.Styled exposing (Html, div, text, a)
import Html.Styled.Attributes exposing (css, href, class)
import Common.Title.Model as Title exposing (Title)
import Common.Article.Model exposing (ArticleError(..))


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
    a
        [ href (toUrl title) ]
        [ text (Title.value title) ]


toUrl : Title -> String
toUrl title =
    "https://en.wikipedia.org/wiki/" ++ (Title.value title)


viewSpinner : Bool -> Html msg
viewSpinner isVisible =
    let
        visibilityValue =
            if isVisible then
                visibility visible
            else
                visibility hidden
    in
        div
            [ class "lds-ellipsis", css [ visibilityValue ] ]
            (List.repeat 4 <| div [] [])
