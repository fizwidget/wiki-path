module View exposing (view)

import Html exposing (Html, div, input, button, text, h1, h2)
import Html.Attributes exposing (value, type_, style, placeholder)
import Html.Events exposing (onInput, onClick)
import RemoteData exposing (WebData)
import Model exposing (Model, Article)
import Messages exposing (Message(..))


view : Model -> Html Message
view model =
    appStyles
        [ centerChildren
            [ pageHeading
            , titleInputs model
            , fetchArticlesButton
            , articlesContent model
            ]
        ]


appStyles : List (Html message) -> Html message
appStyles children =
    div
        [ style
            [ ( "font-family", "Helvetica" )
            , ( "color", "#f9d094" )
            , ( "background", "#2e2a24" )
            , ( "height", "100vh" )
            ]
        ]
        children


centerChildren : List (Html message) -> Html message
centerChildren children =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-direction", "column" )
            , ( "align-items", "center" )
            ]
        ]
        children


pageHeading : Html message
pageHeading =
    h1
        [ style [ ( "font-size", "400%" ), ( "font-weight", "900" ) ] ]
        [ text "📖 Wikipedia Game 📖" ]


titleInputs : Model -> Html Message
titleInputs { sourceTitleInput, destinationTitleInput } =
    div []
        [ sourceArticleTitleInput sourceTitleInput
        , destinationArticleTitleInput destinationTitleInput
        ]


sourceArticleTitleInput : String -> Html Message
sourceArticleTitleInput =
    articleTitleInput "Source article" SourceArticleTitleChange


destinationArticleTitleInput : String -> Html Message
destinationArticleTitleInput =
    articleTitleInput "Destination article" DestinationArticleTitleChange


articleTitleInput : String -> (String -> Message) -> String -> Html Message
articleTitleInput placeholderText toMessage title =
    input
        [ type_ "text"
        , value title
        , placeholder placeholderText
        , onInput toMessage
        , style
            [ ( "boarder-radius", "10px" )
            , ( "background", "rgba(0, 0, 0, 0.3)" )
            , ( "color", "white" )
            , ( "font-size", "20px" )
            , ( "border", "none" )
            , ( "border-radius", "8px" )
            , ( "padding", "8px" )
            ]
        ]
        []


fetchArticlesButton : Html Message
fetchArticlesButton =
    div
        [ style [ ( "margin", "10px" ) ] ]
        [ button
            [ onClick FetchArticlesRequest
            , style
                [ ( "background", "linear-gradient(to bottom, #eae0c2 5%, #ccc2a6 100%)" )
                , ( "background-color", "#eae0c2" )
                , ( "border-radius", "15px" )
                , ( "border", "2px solid #333029" )
                , ( "cursor", "pointer" )
                , ( "color", "#505739" )
                , ( "font-size", "18px" )
                , ( "font-weight", "bold" )
                , ( "padding", "12px 24px" )
                , ( "text-decoration", "none" )
                , ( "text-shadow", "0px 1px 0px #ffffff" )
                , ( "margin-top", "10px" )
                ]
            ]
            [ text "Fetch articles" ]
        ]


articlesContent : Model -> Html message
articlesContent { sourceArticle, destinationArticle } =
    div [ style [ ( "display", "flex" ), ( "align-items", "top" ) ] ]
        [ displayArticle sourceArticle
        , displayArticle destinationArticle
        ]


displayArticle : WebData (Maybe Article) -> Html message
displayArticle article =
    div [ style [ ( "flex", "1" ), ( "max-width", "50%" ) ] ]
        [ case article of
            RemoteData.NotAsked ->
                text ""

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
