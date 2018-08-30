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
import Article exposing (Article, Preview)
import Path exposing (Path)
import Button


-- MODEL


type Model
    = Success Path
    | Error ErrorDetails


type alias ErrorDetails =
    { error : Error
    , source : Article Preview
    , destination : Article Preview
    }


type Error
    = PathNotFound
    | TooManyRequests



-- INIT


initWithPath : Path -> Model
initWithPath =
    Success


initWithPathNotFoundError : Article Preview -> Article Preview -> Model
initWithPathNotFoundError =
    initWithError PathNotFound


initWithTooManyRequestsError : Article Preview -> Article Preview -> Model
initWithTooManyRequestsError =
    initWithError TooManyRequests


initWithError : Error -> Article Preview -> Article Preview -> Model
initWithError error source destination =
    Error
        { error = error
        , source = source
        , destination = destination
        }



-- VIEW


view : Model -> (Article Preview -> Article Preview -> backMsg) -> Html backMsg
view model toBackMsg =
    div
        [ css
            [ displayFlex
            , alignItems center
            , justifyContent center
            , flexDirection column
            ]
        ]
        [ viewModel model
        , viewBackButton model toBackMsg
        ]


viewModel : Model -> Html msg
viewModel model =
    case model of
        Success pathToDestination ->
            viewSuccess pathToDestination

        Error errorDetails ->
            viewError errorDetails


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
        |> List.map Article.viewAsLink
        |> List.intersperse (text " → ")
        |> div []


viewError : ErrorDetails -> Html msg
viewError { source, destination, error } =
    let
        pathNotFoundMessage =
            [ text "Sorry, couldn't find a path from "
            , Article.viewAsLink source
            , text " to "
            , Article.viewAsLink destination
            , text " 💀"
            ]
    in
        div [ css [ textAlign center ] ]
            (case error of
                PathNotFound ->
                    pathNotFoundMessage

                TooManyRequests ->
                    List.append
                        pathNotFoundMessage
                        [ div [] [ text "We made too many requests to Wikipedia! 😵" ] ]
            )


viewBackButton : Model -> (Article Preview -> Article Preview -> backMsg) -> Html backMsg
viewBackButton model toBackMsg =
    let
        onClick =
            toBackMsg (getSourceArticle model) (getDestinationArticle model)
    in
        div [ css [ margin (px 20) ] ]
            [ Button.view "Back"
                [ Button.Secondary
                , Button.OnClick onClick
                ]
            ]


getSourceArticle : Model -> Article Preview
getSourceArticle model =
    case model of
        Success path ->
            Path.beginning path

        Error { source } ->
            source


getDestinationArticle : Model -> Article Preview
getDestinationArticle model =
    case model of
        Success path ->
            Path.end path

        Error { destination } ->
            destination
