module Setup.View exposing (view)

import Css exposing (..)
import Html.Styled exposing (Html, fromUnstyled, toUnstyled, div, input, button, text, form)
import Html.Styled.Attributes exposing (css, value, type_, placeholder)
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
    form []
        [ titleInputs model
        , div [ css [ displayFlex, alignItems center, justifyContent center ] ]
            [ withSpacing <| viewSpinnerIfLoading model.source
            , withSpacing <| loadArticlesButton model
            , withSpacing <| viewSpinnerIfLoading model.destination
            ]
        ]


withSpacing : Html msg -> Html msg
withSpacing content =
    div [ css [ padding2 (px 0) (px 20) ] ] [ content ]


titleInputs : SetupModel -> Html SetupMsg
titleInputs { sourceTitleInput, destinationTitleInput, source, destination } =
    div [ css [ displayFlex, justifyContent center, flexWrap wrap ] ]
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
        div [ css [ paddingLeft (px 8), paddingRight (px 8), height (px 62) ] ]
            [ fromUnstyled <|
                Form.group []
                    [ Input.text inputOptions
                    , Form.invalidFeedback [] [ toUnstyled <| getErrorMessage article ]
                    , Form.validFeedback [] []
                    ]
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
