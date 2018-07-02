module Page.Finished
    exposing
        ( Model
        , initWithPath
        , initWithPathNotFoundError
        , initWithTooManyRequestsError
        , view
        )

import Bootstrap.Button as ButtonOptions
import Common.Button.View as Button
import Common.Article.Model exposing (Article)
import Common.Title.View as Title
import Common.Path.Model as Path exposing (Path)
import Css exposing (..)
import Html.Styled exposing (Html, fromUnstyled, toUnstyled, h2, h4, div, pre, input, button, text, form)
import Html.Styled.Attributes exposing (css, value, type_, placeholder)


-- MODEL --


type Model
    = Success Path
    | Error { source : Article, destination : Article, error : Error }


type Error
    = PathNotFound
    | TooManyRequests



-- INIT --


initWithPath : Path -> ( Model, Cmd msg )
initWithPath pathToDestination =
    ( Success pathToDestination
    , Cmd.none
    )


initWithPathNotFoundError : Article -> Article -> ( Model, Cmd msg )
initWithPathNotFoundError =
    initWithError PathNotFound


initWithTooManyRequestsError : Article -> Article -> ( Model, Cmd msg )
initWithTooManyRequestsError =
    initWithError TooManyRequests


initWithError : Error -> Article -> Article -> ( Model, Cmd msg )
initWithError error source destination =
    ( Error { source = source, destination = destination, error = error }
    , Cmd.none
    )



-- VIEW --


view : Model -> Html Msg
view model =
    div [ css [ displayFlex, alignItems center, justifyContent center, flexDirection column ] ]
        [ viewModel model
        , viewBackButton
        ]


viewModel : Model -> Html msg
viewModel model =
    case model of
        Success pathToDestination ->
            viewSuccess pathToDestination

        Error { source, destination, error } ->
            viewError source destination error


viewSuccess : Path -> Html msg
viewSuccess pathToDestination =
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


viewError : Article -> Article -> Error -> Html msg
viewError source destination error =
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


viewBackButton : Html Msg
viewBackButton =
    div [ css [ margin (px 20) ] ]
        [ Button.view
            [ ButtonOptions.secondary, ButtonOptions.onClick BackToSetup ]
            [ text "Back" ]
        ]
