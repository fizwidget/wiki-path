module Setup.View exposing (view)

import Html exposing (Html, div, input, button, text)
import Html.Attributes exposing (value, type_, style, placeholder)
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import RemoteData
import Common.Model.Article exposing (RemoteArticle, ArticleError(..))
import Common.View exposing (viewSpinner)
import Setup.Messages exposing (SetupMsg(..))
import Setup.Model exposing (SetupModel)


view : SetupModel -> Html SetupMsg
view model =
    Form.form []
        [ titleInputs model
        , div [ style [ ( "display", "flex" ), ( "align-items", "center" ), ( "justify-content", "space-evenly" ) ] ]
            [ viewSpinnerIfLoading model.sourceArticle
            , loadArticlesButton model
            , viewSpinnerIfLoading model.destinationArticle
            ]
        ]


titleInputs : SetupModel -> Html SetupMsg
titleInputs { sourceTitleInput, destinationTitleInput, sourceArticle, destinationArticle } =
    div [ style [ ( "display", "flex" ), ( "justify-content", "space-evenly" ), ( "height", "60px" ) ] ]
        [ sourceArticleTitleInput sourceTitleInput sourceArticle
        , destinationArticleTitleInput destinationTitleInput destinationArticle
        ]


sourceArticleTitleInput : String -> RemoteArticle -> Html SetupMsg
sourceArticleTitleInput =
    articleTitleInput "From..." SourceArticleTitleChange


destinationArticleTitleInput : String -> RemoteArticle -> Html SetupMsg
destinationArticleTitleInput =
    articleTitleInput "To..." DestinationArticleTitleChange


articleTitleInput : String -> (String -> SetupMsg) -> String -> RemoteArticle -> Html SetupMsg
articleTitleInput placeholderText toMsg title article =
    Form.group []
        [ Input.text
            ([ Input.onInput toMsg
             , Input.value title
             , Input.placeholder placeholderText
             ]
                ++ (getInputStatus article)
            )
        , Form.invalidFeedback [] [ text (getErrorMessage article) ]
        , Form.validFeedback [] []
        ]


getInputStatus : RemoteArticle -> List (Input.Option msg)
getInputStatus article =
    case article of
        RemoteData.NotAsked ->
            []

        RemoteData.Loading ->
            []

        RemoteData.Failure _ ->
            [ Input.danger ]

        RemoteData.Success _ ->
            [ Input.success ]


loadArticlesButton : SetupModel -> Html SetupMsg
loadArticlesButton model =
    Form.row [ Row.centerLg ]
        [ Form.col [ Col.lgAuto ]
            [ Button.button
                [ Button.primary
                , Button.disabled (shouldDisableLoadButton model)
                , Button.onClick FetchArticlesRequest
                ]
                [ text "Find path" ]
            ]
        ]


shouldDisableLoadButton : SetupModel -> Bool
shouldDisableLoadButton { sourceTitleInput, destinationTitleInput } =
    let
        isEmpty =
            String.trim >> String.isEmpty
    in
        isEmpty sourceTitleInput || isEmpty destinationTitleInput


viewSpinnerIfLoading : RemoteArticle -> Html msg
viewSpinnerIfLoading article =
    div [] [ viewSpinner <| RemoteData.isLoading article ]


getErrorMessage : RemoteArticle -> String
getErrorMessage remoteArticle =
    case remoteArticle of
        RemoteData.Failure error ->
            case error of
                ArticleNotFound ->
                    "Couldn't find that article :("

                InvalidTitle ->
                    "Not a valid article title :("

                UnknownError errorCode ->
                    ("Unknown error: " ++ errorCode)

                NetworkError error ->
                    ("Network error: " ++ toString error)

        _ ->
            ""