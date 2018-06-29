module Page.Setup.View exposing (view)

import Css exposing (..)
import Html.Styled exposing (Html, fromUnstyled, toUnstyled, div, pre, input, button, text, form)
import Html.Styled.Attributes exposing (css, value, type_, placeholder)
import RemoteData
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Button as ButtonOptions
import Common.Button.View as Button
import Common.Error.View as Error
import Common.Article.Model exposing (RemoteArticle, ArticleError(..))
import Common.Article.View as Article
import Common.Spinner.View as Spinner
import Page.Setup.Messages exposing (SetupMsg(..))
import Page.Setup.Model exposing (SetupModel, UserInput)


view : SetupModel -> Html SetupMsg
view model =
    form
        [ css [ displayFlex, alignItems center, flexDirection column ] ]
        [ titleInputs model
        , findPathButton model
        , randomizeTitlesButton model
        , showRandomizationError model
        , showSpinnerIfLoading model
        ]


titleInputs : SetupModel -> Html SetupMsg
titleInputs ({ sourceTitleInput, destinationTitleInput, source, destination } as model) =
    let
        inputStatus =
            if isLoading model then
                Disabled
            else
                Enabled
    in
        div [ css [ displayFlex, justifyContent center, flexWrap wrap ] ]
            [ viewSourceTitleInput sourceTitleInput source inputStatus
            , viewDestinationTitleInput destinationTitleInput destination inputStatus
            ]


type InputStatus
    = Enabled
    | Disabled


viewSourceTitleInput : UserInput -> RemoteArticle -> InputStatus -> Html SetupMsg
viewSourceTitleInput =
    articleTitleInput "From..." SourceArticleTitleChange


viewDestinationTitleInput : UserInput -> RemoteArticle -> InputStatus -> Html SetupMsg
viewDestinationTitleInput =
    articleTitleInput "To..." DestinationArticleTitleChange


articleTitleInput : String -> (UserInput -> SetupMsg) -> UserInput -> RemoteArticle -> InputStatus -> Html SetupMsg
articleTitleInput placeholderText toMsg title article inputStatus =
    let
        isDisabled =
            case inputStatus of
                Enabled ->
                    False

                Disabled ->
                    True

        inputOptions =
            getInputStatus article
                ++ [ Input.large
                   , Input.onInput toMsg
                   , Input.value title
                   , Input.placeholder placeholderText
                   , Input.disabled isDisabled
                   ]
    in
        div [ css [ padding2 (px 0) (px 8), height (px 76) ] ]
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
            []


findPathButton : SetupModel -> Html SetupMsg
findPathButton model =
    div [ css [ padding (px 4) ] ]
        [ Button.view
            [ ButtonOptions.primary
            , ButtonOptions.large
            , ButtonOptions.disabled (shouldDisableLoadButton model)
            , ButtonOptions.onClick FetchArticlesRequest
            ]
            [ text "Find path" ]
        ]


randomizeTitlesButton : SetupModel -> Html SetupMsg
randomizeTitlesButton model =
    div [ css [ padding (px 12) ] ]
        [ Button.view
            [ ButtonOptions.large
            , ButtonOptions.light
            , ButtonOptions.disabled (isLoading model)
            , ButtonOptions.onClick FetchRandomTitlesRequest
            ]
            [ text "Randomize" ]
        ]


showRandomizationError : SetupModel -> Html msg
showRandomizationError { randomTitles } =
    case randomTitles of
        RemoteData.Failure error ->
            Error.view "Error randomizing titles 😵" (toString error)

        _ ->
            text ""


shouldDisableLoadButton : SetupModel -> Bool
shouldDisableLoadButton model =
    let
        isBlank =
            String.trim >> String.isEmpty
    in
        isLoading model
            || isBlank model.sourceTitleInput
            || isBlank model.destinationTitleInput


showSpinnerIfLoading : SetupModel -> Html msg
showSpinnerIfLoading model =
    div
        [ css [ paddingTop (px 6) ] ]
        [ Spinner.view { isVisible = isLoading model } ]


isLoading : SetupModel -> Bool
isLoading { source, destination, randomTitles } =
    let
        areArticlesLoading =
            [ source, destination ]
                |> RemoteData.fromList
                |> RemoteData.isLoading

        areTitlesLoading =
            RemoteData.isLoading randomTitles
    in
        areArticlesLoading || areTitlesLoading


getErrorMessage : RemoteArticle -> Html msg
getErrorMessage remoteArticle =
    case remoteArticle of
        RemoteData.Failure error ->
            Article.viewError error

        _ ->
            text ""
