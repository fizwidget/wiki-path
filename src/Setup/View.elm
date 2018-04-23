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
import Common.View exposing (viewSpinner, viewArticleError)
import Setup.Messages exposing (SetupMsg(..))
import Setup.Model exposing (SetupModel, UserInput)


view : SetupModel -> Html SetupMsg
view model =
    Form.form []
        [ titleInputs model
        , div [ style [ ( "display", "flex" ), ( "align-items", "center" ), ( "justify-content", "space-evenly" ) ] ]
            [ viewSpinnerIfLoading model.source
            , loadArticlesButton model
            , viewSpinnerIfLoading model.destination
            ]
        ]


titleInputs : SetupModel -> Html SetupMsg
titleInputs { sourceTitleInput, destinationTitleInput, source, destination } =
    div [ style [ ( "display", "flex" ), ( "justify-content", "space-evenly" ), ( "height", "60px" ) ] ]
        [ viewSourceTitleInput sourceTitleInput source
        , viewDestinationTitleInput destinationTitleInput destination
        ]


viewSourceTitleInput : UserInput -> RemoteArticle -> Html SetupMsg
viewSourceTitleInput =
    articleTitleInput "From..." SourceArticleTitleChange


viewDestinationTitleInput : UserInput -> RemoteArticle -> Html SetupMsg
viewDestinationTitleInput =
    articleTitleInput "To..." DestinationArticleTitleChange


articleTitleInput : String -> (UserInput -> SetupMsg) -> UserInput -> RemoteArticle -> Html SetupMsg
articleTitleInput placeholderText toMsg title article =
    Form.group []
        [ Input.text
            ([ Input.onInput toMsg
             , Input.value title
             , Input.placeholder placeholderText
             ]
                ++ (getInputStatus article)
            )
        , Form.invalidFeedback [] [ getErrorMessage article ]
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


getErrorMessage : RemoteArticle -> Html msg
getErrorMessage remoteArticle =
    case remoteArticle of
        RemoteData.Failure error ->
            viewArticleError error

        _ ->
            text ""
