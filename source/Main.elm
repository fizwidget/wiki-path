module Main exposing (main)

import Css exposing (..)
import Html
import Html.Styled as Html exposing (Html, toUnstyled, div, h1, text)
import Html.Styled.Attributes as Attributes exposing (css)
import Page.Finished as Finished
import Page.Pathfinding as Pathfinding
import Page.Setup as Setup


-- MAIN --


main : Program Never Model Msg
main =
    Html.program
        { init = Setup.init
        , view = View.view >> toUnstyled
        , update = Update.update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL --


type Model
    = Setup Setup.Model
    | Pathfinding Pathfinding.Model
    | Finished Finished.Model



-- MESSAGES --


type Msg
    = Setup Setup.Msg
    | Pathfinding Pathfinding.Msg
    | BackToSetup



-- UPDATE --


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( Messages.BackToSetup, _ ) ->
            Setup.init

        ( Messages.Setup innerMsg, Model.Setup innerModel ) ->
            case Setup.update innerMsg innerModel of
                Setup.InSetup output ->
                    output

                Setup.Done source destination ->
                    Pathfinding.init source destination

        ( Messages.Pathfinding innerMsg, Model.Pathfinding innerModel ) ->
            case Pathfinding.update innerMsg innerModel of
                Pathfinding.InPathfinding output ->
                    output

                Pathfinding.Done pathToDestination ->
                    Finished.initWithPath pathToDestination

                Pathfinding.Back ->
                    Setup.init

        ( Messages.Finished innerMsg, Model.Finished innerModel ) ->
            Finished.update innerMsg innerModel

        ( _, _ ) ->
            ( model, Cmd.none )



-- VIEW --


view : Model -> Html Msg
view model =
    div
        [ css
            [ fontSize (px 24)
            , maxWidth (px 800)
            , padding (px 20)
            , marginLeft auto
            , marginRight auto
            ]
        ]
        [ viewHeading
        , viewModel model
        ]


viewHeading : Html msg
viewHeading =
    h1
        [ css
            [ fontSize (vh 10)
            , fontWeight (int 900)
            , fontFamily serif
            , textAlign center
            , marginTop (px 50)
            , marginBottom (px 34)
            ]
        ]
        [ text "WikiPath" ]


viewModel : Model -> Html Msg
viewModel model =
    case model of
        Model.Setup innerModel ->
            Setup.view innerModel
                |> Html.map Messages.Setup

        Model.Pathfinding innerModel ->
            Pathfinding.view innerModel

        Model.Finished innerModel ->
            Finished.view innerModel
