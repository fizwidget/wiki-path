module Page.Finished
    exposing
        ( Model(Success, Error)
        , Error(PathNotFound, TooManyRequests)
        , view
        )

import Bootstrap.Button as ButtonOptions
import Common.Article exposing (Article)
import Common.Button as Button
import Common.Path as Path exposing (Path)
import Common.Title as Title
import Css exposing (..)
import Html.Styled exposing (Html, fromUnstyled, toUnstyled, h2, h4, div, pre, input, button, text, form)
import Html.Styled.Attributes exposing (css, value, type_, placeholder)


-- Model


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



-- View


view : Model -> backMsg -> Html backMsg
view model backMsg =
    div [ css [ displayFlex, alignItems center, justifyContent center, flexDirection column ] ]
        [ viewModel model
        , viewBackButton backMsg
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


viewBackButton : msg -> Html msg
viewBackButton msg =
    div [ css [ margin (px 20) ] ]
        [ Button.view
            [ ButtonOptions.secondary, ButtonOptions.onClick msg ]
            [ text "Back" ]
        ]
