module Page.Finished.View exposing (view)

import Css exposing (..)
import Html.Styled exposing (Html, fromUnstyled, toUnstyled, div, h2, h4, text, a)
import Html.Styled.Attributes exposing (css)
import Bootstrap.Button as ButtonOptions
import View.Button as Button
import Data.Article exposing (Article)
import Data.Path as Path exposing (Path)
import View.Title as Title
import Page.Finished.Model exposing (FinishedModel(Success, Error), Error(PathNotFound, TooManyRequests))
import Page.Finished.Messages exposing (FinishedMsg(BackToSetup))


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

        Error { source, destination, error } ->
            errorView source destination error


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


errorView : Article -> Article -> Error -> Html msg
errorView source destination error =
    let
        baseErrorMessage =
            [ text "Sorry, couldn't find a path from "
            , Title.viewAsLink source.title
            , text " to "
            , Title.viewAsLink destination.title
            , text " 💀"
            ]
    in
        div [ css [ textAlign center ] ]
            (case error of
                PathNotFound ->
                    baseErrorMessage

                TooManyRequests ->
                    List.append
                        baseErrorMessage
                        [ div [] [ text "We made too many requests to Wikipedia! 😵" ] ]
            )


backButton : Html FinishedMsg
backButton =
    div [ css [ margin (px 20) ] ]
        [ Button.view
            [ ButtonOptions.secondary, ButtonOptions.onClick BackToSetup ]
            [ text "Back" ]
        ]
