module FinishedPage.View exposing (view)

import Html exposing (Html, div, h3, h4, text)
import Common.Model exposing (Title(Title), Article, getTitle)
import FinishedPage.Model exposing (Model, Path)
import FinishedPage.Messages exposing (Msg)


view : Model -> Html Msg
view model =
    case model of
        Result.Ok path ->
            successView path

        Result.Err error ->
            errorView error


successView : Path -> Html msg
successView { source, destination, path } =
    div []
        [ headingView
        , subHeadingView source destination
        , pathView path
        ]


errorView : String -> Html msg
errorView error =
    text <| "Error when finding path: " ++ error


headingView : Html msg
headingView =
    h3 [] [ text "Success!" ]


subHeadingView : Article -> Article -> Html msg
subHeadingView source destination =
    h4 []
        [ text <| "Path from " ++ (getTitle source) ++ " to " ++ (getTitle destination) ++ "  was..." ]


pathView : List Title -> Html msg
pathView path =
    path
        |> List.reverse
        |> List.map (\(Title title) -> title)
        |> String.join " → "
        |> text
