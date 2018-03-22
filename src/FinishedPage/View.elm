module FinishedPage.View exposing (view)

import Html exposing (Html, div, h3, h4, text)
import Common.Model exposing (Title(Title), Article, getTitle, unbox)
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
successView { start, end, stops } =
    div []
        [ headingView
        , subHeadingView start end
        , stopsView stops
        ]


errorView : String -> Html msg
errorView error =
    text <| "Error when finding path: " ++ error


headingView : Html msg
headingView =
    h3 [] [ text "Success!" ]


subHeadingView : Title -> Title -> Html msg
subHeadingView startTitle endTitle =
    h4 []
        [ text <| "Path from " ++ (unbox startTitle) ++ " to " ++ (unbox endTitle) ++ "  was..." ]


stopsView : List Title -> Html msg
stopsView stops =
    stops
        |> List.reverse
        |> List.map unbox
        |> String.join " → "
        |> text
