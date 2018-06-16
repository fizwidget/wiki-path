module Finished.View exposing (view)

import Css exposing (..)
import Html.Styled exposing (Html, fromUnstyled, toUnstyled, div, h2, h4, text, a)
import Html.Styled.Attributes exposing (css)
import Bootstrap.Button as ButtonOptions
import Common.Button.View as Button
import Common.Path.Model as Path exposing (Path)
import Common.Title.View as Title
import Finished.Model exposing (FinishedModel(Success, Error), Error(PathNotFound, TooManyRequests))
import Finished.Messages exposing (FinishedMsg(BackToSetup))


view : FinishedModel -> Html FinishedMsg
view model =
    div [ css [ displayFlex, alignItems center, justifyContent center, flexDirection column ] ]
        [ modelView model
        , backButton
        ]


modelView : FinishedModel -> Html msg
modelView model =
    case model of
        Success pathToDestination ->
            successView pathToDestination

        Error error ->
            errorView error


successView : Path -> Html msg
successView pathToDestination =
    div [ css [ textAlign center ] ]
        [ headingView
        , subHeadingView
        , pathView pathToDestination
        ]


headingView : Html msg
headingView =
    h2 [] [ text "Success!" ]


subHeadingView : Html msg
subHeadingView =
    h4 [] [ text "Path was... " ]


pathView : Path -> Html msg
pathView path =
    Path.inOrder path
        |> List.map Title.viewAsLink
        |> List.intersperse (text " → ")
        |> div []


errorView : Error -> Html msg
errorView error =
    case error of
        PathNotFound ->
            text "Sorry, couldn't find a path 💀"

        TooManyRequests ->
            text "Sorry, we're making too many requests to Wikipedia! 😵"


backButton : Html FinishedMsg
backButton =
    div [ css [ margin (px 20) ] ]
        [ Button.view
            [ ButtonOptions.secondary, ButtonOptions.onClick BackToSetup ]
            [ text "Back" ]
        ]
