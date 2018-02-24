module View exposing (view)

import Html exposing (Html, div, input, button, text)
import Html.Attributes exposing (value, type_)
import Html.Events exposing (onInput, onClick)
import Model exposing (Model, Article)
import Messages exposing (Message(..))
import RemoteData exposing (WebData)


view : Model -> Html Message
view model =
    div []
        [ articleTitleInput model.title
        , fetchArticleButton
        , articleContent model.article
        ]


articleTitleInput : String -> Html Message
articleTitleInput url =
    input [ type_ "text", value url, onInput ArticleTitleChange ] []


fetchArticleButton : Html Message
fetchArticleButton =
    button [ onClick FetchArticleRequest ] [ text "Request article" ]


articleContent : WebData (Maybe Article) -> Html Message
articleContent article =
    div []
        [ text <|
            case article of
                RemoteData.NotAsked ->
                    ""

                RemoteData.Loading ->
                    "Loading..."

                RemoteData.Success value ->
                    case value of
                        Just a ->
                            a.content

                        Nothing ->
                            "Article has no content? D:"

                RemoteData.Failure error ->
                    ("Oops, could not load article :(\n" ++ (toString error))
        ]
