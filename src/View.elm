module View exposing (view)

import Html exposing (Html, div, input, button, text, h1, h2)
import Html.Attributes exposing (value, type_, style)
import Html.Events exposing (onInput, onClick)
import RemoteData exposing (WebData)
import Model exposing (Model, Article)
import Messages exposing (Message(..))


view : Model -> Html Message
view model =
    div [ style [ ( "font-family", "Helvetica" ) ] ]
        [ heading
        , sourceArticleTitleInput model.sourceTitleInput
        , destinationArticleTitleInput model.destinationTitleInput
        , fetchArticlesButton
        , articlesContent model.sourceArticle model.destinationArticle
        ]


heading : Html message
heading =
    div [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ]
        [ h1 [] [ text "Wikipedia game" ] ]


sourceArticleTitleInput : String -> Html Message
sourceArticleTitleInput =
    articleTitleInput SourceArticleTitleChange


destinationArticleTitleInput : String -> Html Message
destinationArticleTitleInput =
    articleTitleInput DestinationArticleTitleChange


articleTitleInput : (String -> Message) -> String -> Html Message
articleTitleInput toMessage title =
    input [ type_ "text", value title, onInput toMessage ] []


fetchArticlesButton : Html Message
fetchArticlesButton =
    div [] [ button [ onClick FetchArticlesRequest ] [ text "Fetch articles" ] ]


articlesContent : WebData (Maybe Article) -> WebData (Maybe Article) -> Html message
articlesContent source destination =
    div [ style [ ( "display", "flex" ), ( "align-items", "top" ) ] ]
        [ displayArticle source
        , displayArticle destination
        ]


displayArticle : WebData (Maybe Article) -> Html message
displayArticle article =
    div [ style [ ( "flex", "1" ), ( "max-width", "50%" ) ] ]
        [ case article of
            RemoteData.NotAsked ->
                text "-"

            RemoteData.Loading ->
                text "Loading..."

            RemoteData.Success article ->
                case article of
                    Just { title, content } ->
                        div []
                            [ h2 [] [ text title ]
                            , text content
                            ]

                    Nothing ->
                        text "Article not found"

            RemoteData.Failure error ->
                text ("Oops, couldn't load article:\n" ++ (toString error))
        ]
