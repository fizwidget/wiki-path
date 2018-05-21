module Finished.View exposing (view)

import Css exposing (..)
import Html.Styled exposing (Html, fromUnstyled, toUnstyled, div, h2, h4, text, a)
import Html.Styled.Attributes exposing (css)
import Bootstrap.Button as ButtonOptions
import Common.Button.View as Button
import Common.Path.Model exposing (Path)
import Common.Title.Model as Title exposing (Title)
import Common.Title.View as Title
import Finished.Model exposing (FinishedModel(Success, Error), Error(PathNotFound, TooManyRequests))
import Finished.Messages exposing (FinishedMsg(BackToSetup))


view : FinishedModel -> Html FinishedMsg
view model =
    div [ css [ displayFlex, alignItems center, justifyContent center, flexDirection column ] ]
        [ headingView
        , subHeadingView
        , modelView model
        , backButton
        ]


modelView : FinishedModel -> Html msg
modelView model =
    case model of
        Success path ->
            pathView path

        Error error ->
            errorView error


headingView : Html msg
headingView =
    h2 [] [ text "Success!" ]


subHeadingView : Html msg
subHeadingView =
    h4 [] [ text "Path was... " ]


pathView : Path -> Html msg
pathView path =
    let
        stops =
            (path.next :: path.visited) |> List.reverse
    in
        stops
            |> List.map Title.viewAsLink
            |> List.intersperse (text " → ")
            |> div []


errorView : Error -> Html msg
errorView error =
    case error of
        PathNotFound ->
            text "Path not found :("

        TooManyRequests ->
            text "Sorry, too many requests!"


backButton : Html FinishedMsg
backButton =
    div [ css [ margin (px 20) ] ]
        [ Button.view
            [ ButtonOptions.secondary, ButtonOptions.onClick BackToSetup ]
            [ text "Back" ]
        ]
