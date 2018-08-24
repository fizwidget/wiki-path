module Page.Finished
    exposing
        ( Model
        , initWithPath
        , initWithPathNotFoundError
        , initWithTooManyRequestsError
        , view
        )

import Html.Styled exposing (Html, fromUnstyled, toUnstyled, h2, h4, div, pre, input, button, text, form)
import Html.Styled.Attributes exposing (css, value, type_, placeholder)
import Css exposing (..)
import Bootstrap.Button as ButtonOptions
import Data.Article exposing (Article)
import Data.Path as Path exposing (Path)
import Data.Title as Title exposing (Title)
import View.Button as Button
import View.Link as Link


-- MODEL


type Model
    = Success Path
    | Error
        { error : Error
        , source : Article
        , destination : Article
        }


type Error
    = PathNotFound
    | TooManyRequests



-- INIT


initWithPath : Path -> Model
initWithPath =
    Success


initWithPathNotFoundError : Article -> Article -> Model
initWithPathNotFoundError =
    initWithError PathNotFound


initWithTooManyRequestsError : Article -> Article -> Model
initWithTooManyRequestsError =
    initWithError TooManyRequests


initWithError : Error -> Article -> Article -> Model
initWithError error source destination =
    Error
        { error = error
        , source = source
        , destination = destination
        }



-- VIEW


view : Model -> (Title -> Title -> backMsg) -> Html backMsg
view model toBackMsg =
    div [ css [ displayFlex, alignItems center, justifyContent center, flexDirection column ] ]
        [ viewModel model
        , viewBackButton model toBackMsg
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
        [ viewHeading
        , viewSubHeading
        , viewPath pathToDestination
        ]


viewHeading : Html msg
viewHeading =
    h2 [] [ text "Success!" ]


viewSubHeading : Html msg
viewSubHeading =
    h4 [] [ text "Path was... " ]


viewPath : Path -> Html msg
viewPath path =
    Path.inOrder path
        |> List.map Link.view
        |> List.intersperse (text " → ")
        |> div []


viewError : Article -> Article -> Error -> Html msg
viewError source destination error =
    let
        baseErrorMessage =
            [ text "Sorry, couldn't find a path from "
            , Link.view source.title
            , text " to "
            , Link.view destination.title
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


viewBackButton : Model -> (Title -> Title -> backMsg) -> Html backMsg
viewBackButton model toBackMsg =
    let
        onClick =
            toBackMsg (getSource model) (getDestination model)
    in
        div [ css [ margin (px 20) ] ]
            [ Button.view
                [ ButtonOptions.secondary, ButtonOptions.onClick onClick ]
                [ text "Back" ]
            ]


getSource : Model -> Title
getSource model =
    case model of
        Success path ->
            Path.beginning path

        Error { source } ->
            source.title


getDestination : Model -> Title
getDestination model =
    case model of
        Success path ->
            Path.end path

        Error { destination } ->
            destination.title
