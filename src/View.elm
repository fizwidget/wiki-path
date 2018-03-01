module View exposing (view)

import Html exposing (Html, div, input, button, text, span, h1, h2)
import Html.Attributes exposing (value, type_, style, placeholder)
import Html.Events exposing (onInput, onClick)
import RemoteData exposing (WebData)
import Model exposing (Model, ArticleResult, RemoteArticle, Article, ApiError(..))
import Messages exposing (Message(..))


view : Model -> Html Message
view model =
    appStyles
        [ centerChildren
            [ pageIcon "📖"
            , pageHeading "Wikipedia Game"
            , titleInputs model
            , loadArticlesButton
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
            , ( "min-height", "100vh" )
            , ( "padding", "20px" )
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


pageIcon : String -> Html Message
pageIcon icon =
    span
        [ style
            [ ( "font-size", "800%" )
            , ( "line-height", "1" )
            , ( "height", "120px" )
            , ( "margin", "20px 0 10px 0" )
            ]
        ]
        [ text icon ]


pageHeading : String -> Html message
pageHeading heading =
    h1
        [ style
            [ ( "font-size", "400%" )
            , ( "font-weight", "900" )
            , ( "margin-top", "0" )
            ]
        ]
        [ text heading ]


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
            , ( "text-align", "center" )
            , ( "margin-right", "8px" )
            ]
        ]
        []


loadArticlesButton : Html Message
loadArticlesButton =
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
                , ( "padding", "10px 20px" )
                , ( "text-decoration", "none" )
                , ( "text-shadow", "0px 1px 0px #ffffff" )
                , ( "margin-top", "10px" )
                ]
            ]
            [ text "Load articles" ]
        ]


articlesContent : Model -> Html message
articlesContent { sourceArticle, destinationArticle } =
    div [ style [ ( "display", "flex" ), ( "align-items", "top" ) ] ]
        [ displayRemoteArticle sourceArticle
        , displayRemoteArticle destinationArticle
        ]


displayRemoteArticle : RemoteArticle -> Html message
displayRemoteArticle article =
    div [ style [ ( "flex", "1" ), ( "max-width", "50%" ) ] ]
        [ case article of
            RemoteData.NotAsked ->
                text ""

            RemoteData.Loading ->
                text "Loading..."

            RemoteData.Success articleResult ->
                displayArticleResult articleResult

            RemoteData.Failure error ->
                text (toString error)
        ]


displayArticleResult : ArticleResult -> Html message
displayArticleResult article =
    case article of
        Result.Err error ->
            displayError error

        Result.Ok article ->
            displaySuccess article


displaySuccess : Article -> Html message
displaySuccess { title, content } =
    div []
        [ h2 [] [ text title ]
        , text content
        ]


displayError : ApiError -> Html message
displayError error =
    case error of
        ArticleNotFound ->
            text "Article not found"

        UnknownError errorCode ->
            text ("Unknown error: " ++ errorCode)
