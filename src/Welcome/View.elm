module Welcome.View exposing (view)

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
import Welcome.Messages exposing (WelcomeMsg(..))
import Welcome.Model exposing (WelcomeModel)


view : WelcomeModel -> Html WelcomeMsg
view model =
    Form.form []
        [ titleInputs model
        , Form.row [ Row.centerLg, Row.middleLg ]
            [ Form.col [ Col.lgAuto ] [ viewSpinnerIfLoading model.startArticle ]
            , Form.col [ Col.lgAuto ] [ loadArticlesButton model ]
            , Form.col [ Col.lgAuto ] [ viewSpinnerIfLoading model.endArticle ]
            ]
        ]


titleInputs : WelcomeModel -> Html WelcomeMsg
titleInputs { startTitleInput, endTitleInput, startArticle, endArticle } =
    Form.row []
        [ Form.col [] [ startArticleTitleInput startTitleInput startArticle ]
        , Form.col [] [ endArticleTitleInput endTitleInput endArticle ]
        ]


startArticleTitleInput : String -> RemoteArticle -> Html WelcomeMsg
startArticleTitleInput =
    articleTitleInput "From..." StartArticleTitleChange


endArticleTitleInput : String -> RemoteArticle -> Html WelcomeMsg
endArticleTitleInput =
    articleTitleInput "To..." EndArticleTitleChange


articleTitleInput : String -> (String -> WelcomeMsg) -> String -> RemoteArticle -> Html WelcomeMsg
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
        , Form.validFeedback [] [ text "Got it!" ]
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


loadArticlesButton : WelcomeModel -> Html WelcomeMsg
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


shouldDisableLoadButton : WelcomeModel -> Bool
shouldDisableLoadButton { startTitleInput, endTitleInput } =
    let
        isEmpty =
            String.trim >> String.isEmpty
    in
        isEmpty startTitleInput || isEmpty endTitleInput


articlesContent : RemoteArticle -> RemoteArticle -> Html msg
articlesContent startArticle endArticle =
    div [ style [ ( "display", "flex" ), ( "text-align", "center" ) ] ]
        [ viewSpinnerIfLoading startArticle
        , viewSpinnerIfLoading endArticle
        ]


viewSpinnerIfLoading : RemoteArticle -> Html msg
viewSpinnerIfLoading article =
    div [ style [ ( "flex", "1" ), ( "max-width", "50%" ) ] ]
        [ if RemoteData.isLoading article then
            viewSpinner
          else
            text ""
        ]


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

        RemoteData.Success article ->
            "Got it!"

        _ ->
            ""
