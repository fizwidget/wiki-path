module View exposing (view)

import Html exposing (Html, div, input, button, text)
import Html.Attributes exposing (value, type_)
import Html.Events exposing (onInput, onClick)
import Model exposing (Model, Url, Article)
import Messages exposing (Message(..))
import RemoteData exposing (WebData)


view : Model -> Html Message
view model =
    div []
        [ articleUrlInput model.articleUrl
        , fetchArticleButton
        , articleContent model.articleContent
        ]


articleUrlInput : Url -> Html Message
articleUrlInput url =
    input [ type_ "text", value url, onInput ArticleUrlChange ] []


fetchArticleButton : Html Message
fetchArticleButton =
    button [ onClick FetchArticleRequest ] [ text "Request article" ]


articleContent : WebData Article -> Html Message
articleContent content =
    div []
        [ case content of
            RemoteData.NotAsked ->
                text ""

            RemoteData.Loading ->
                text "Loading..."

            RemoteData.Success value ->
                text value

            RemoteData.Failure error ->
                text ("Oops, could not load article :(\n" ++ (toString error))
        ]
