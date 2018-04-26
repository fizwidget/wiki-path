module Setup.View exposing (view)

import Html.Styled exposing (Html, fromUnstyled, toUnstyled, div, input, button, text)
import Html.Styled.Attributes exposing (value, type_, style, placeholder)
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import RemoteData
import Common.Article.Model exposing (RemoteArticle, ArticleError(..))
import Common.View exposing (viewSpinner, viewArticleError)
import Setup.Messages exposing (SetupMsg(..))
import Setup.Model exposing (SetupModel, UserInput)


view : SetupModel -> Html SetupMsg
view model =
    fromUnstyled <|
        Form.form []
            [ toUnstyled <| titleInputs model
            , toUnstyled <|
                div [ style [ ( "display", "flex" ), ( "align-items", "center" ), ( "justify-content", "space-evenly" ) ] ]
                    [ viewSpinnerIfLoading model.source
                    , loadArticlesButton model
                    , viewSpinnerIfLoading model.destination
                    ]
            ]


titleInputs : SetupModel -> Html SetupMsg
titleInputs { sourceTitleInput, destinationTitleInput, source, destination } =
    div [ style [ ( "display", "flex" ), ( "justify-content", "space-evenly" ), ( "flex-wrap", "wrap" ) ] ]
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
    let
        inputOptions =
            getInputStatus article
                ++ [ Input.onInput toMsg
                   , Input.value title
                   , Input.placeholder placeholderText
                   ]
    in
        fromUnstyled <|
            Form.group []
                [ Input.text inputOptions
                , Form.invalidFeedback [] [ toUnstyled <| getErrorMessage article ]
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
    fromUnstyled <|
        Button.button
            [ Button.primary
            , Button.disabled (shouldDisableLoadButton model)
            , Button.onClick FetchArticlesRequest
            ]
            [ toUnstyled <| text "Find path" ]


shouldDisableLoadButton : SetupModel -> Bool
shouldDisableLoadButton { sourceTitleInput, destinationTitleInput } =
    let
        isBlank =
            String.trim >> String.isEmpty
    in
        isBlank sourceTitleInput || isBlank destinationTitleInput


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
