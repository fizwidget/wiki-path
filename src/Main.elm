module Main exposing (..)

import Html exposing (Html, button, div, span, input, text)
import Html.Attributes exposing (placeholder, defaultValue)
import Html.Events exposing (onClick, onInput)


-- Main


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = model
        , view = view
        , update = update
        }



-- Model


type alias Model =
    { source : String
    , destination : String
    }


model : Model
model =
    Model "" ""



-- Update


type Msg
    = ChangeSource String
    | ChangeDestination String


update : Msg -> Model -> Model
update msg model =
    case msg of
        ChangeSource source ->
            { model | source = source }

        ChangeDestination destination ->
            { model | destination = destination }



-- View


view : Model -> Html Msg
view model =
    div []
        [ input [ defaultValue model.source, onInput ChangeSource ]
            []
        , div [] [ text model.source ]
        , input
            [ defaultValue model.destination, onInput ChangeDestination ]
            []
        , div [] [ text model.destination ]
        ]
