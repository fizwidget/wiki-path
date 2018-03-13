module WelcomePage.View exposing (view)

import Html exposing (Html, div, input, button, text)
import Html.Attributes exposing (value, type_, style, placeholder)
import Html.Events exposing (onInput, onClick)
import RemoteData
import Common.Model exposing (RemoteArticle, ArticleError(..))
import WelcomePage.Model
import WelcomePage.Messages exposing (Msg(..))
import WelcomePage.Model exposing (Model)


view : WelcomePage.Model.Model -> Html Msg
view model =
    div []
        [ titleInputs model
        , loadArticlesButton
        , articlesContent model.sourceArticle model.destinationArticle
        ]


titleInputs : Model -> Html Msg
titleInputs { sourceTitleInput, destinationTitleInput } =
    div []
        [ sourceArticleTitleInput sourceTitleInput
        , destinationArticleTitleInput destinationTitleInput
        ]


sourceArticleTitleInput : String -> Html Msg
sourceArticleTitleInput =
    articleTitleInput "Source article" SourceArticleTitleChange


destinationArticleTitleInput : String -> Html Msg
destinationArticleTitleInput =
    articleTitleInput "Destination article" DestinationArticleTitleChange


articleTitleInput : String -> (String -> Msg) -> String -> Html Msg
articleTitleInput placeholderText toMsg title =
    input
        [ type_ "text"
        , value title
        , placeholder placeholderText
        , onInput toMsg
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


loadArticlesButton : Html Msg
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


articlesContent : RemoteArticle -> RemoteArticle -> Html msg
articlesContent sourceArticle destinationArticle =
    div [ style [ ( "display", "flex" ), ( "align-items", "top" ) ] ]
        [ displayRemoteArticle sourceArticle
        , displayRemoteArticle destinationArticle
        ]


displayRemoteArticle : RemoteArticle -> Html msg
displayRemoteArticle article =
    div [ style [ ( "flex", "1" ), ( "max-width", "50%" ) ] ]
        [ case article of
            RemoteData.NotAsked ->
                text ""

            RemoteData.Loading ->
                text "Loading..."

            RemoteData.Success article ->
                text "Loaded!"

            RemoteData.Failure error ->
                displayError error
        ]


displayError : ArticleError -> Html msg
displayError error =
    case error of
        ArticleNotFound ->
            text "Not found"

        InvalidTitle ->
            text "Invalid title"

        UnknownError errorCode ->
            text ("Unknown error: " ++ errorCode)

        NetworkError error ->
            text ("Network error: " ++ toString error)
