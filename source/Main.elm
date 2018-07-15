module Main exposing (main)

import Html exposing (program)
import Html.Styled as StyledHtml exposing (Html, toUnstyled, div, h1, text)
import Html.Styled.Attributes as Attributes exposing (css)
import Css exposing (..)
import Util exposing (noCmd)
import Page.Finished as Finished
import Page.Pathfinding as Pathfinding
import Page.Setup as Setup
import Data.Title exposing (Title)


-- Model


type Model
    = SetupPage Setup.Model
    | PathfindingPage Pathfinding.Model
    | FinishedPage Finished.Model



-- Update


type Msg
    = SetupMsg Setup.Msg
    | PathfindingMsg Pathfinding.Msg
    | BackToSetup Title Title


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( BackToSetup source destination, _ ) ->
            initSetupWithSourceAndDestination source destination

        ( SetupMsg msg, SetupPage model ) ->
            Setup.update msg model |> onSetupUpdate

        ( PathfindingMsg msg, PathfindingPage model ) ->
            Pathfinding.update msg model |> onPathfindingUpdate

        ( _, _ ) ->
            ( model, Cmd.none )


onSetupUpdate : Setup.UpdateResult -> ( Model, Cmd Msg )
onSetupUpdate updateResult =
    case updateResult of
        Setup.Continue ( model, cmd ) ->
            inSetupPage ( model, cmd )

        Setup.Done source destination ->
            Pathfinding.init source destination |> onPathfindingUpdate


onPathfindingUpdate : Pathfinding.UpdateResult -> ( Model, Cmd Msg )
onPathfindingUpdate updateResult =
    case updateResult of
        Pathfinding.Continue ( model, cmd ) ->
            inPathfindingPage ( model, cmd )

        Pathfinding.Abort source destination ->
            initSetupWithSourceAndDestination source.title destination.title

        Pathfinding.PathFound path ->
            Finished.Success path
                |> noCmd
                |> inFinishedPage

        Pathfinding.PathNotFound source destination ->
            { error = Finished.PathNotFound, source = source, destination = destination }
                |> Finished.Error
                |> noCmd
                |> inFinishedPage

        Pathfinding.TooManyRequests source destination ->
            { error = Finished.TooManyRequests, source = source, destination = destination }
                |> Finished.Error
                |> noCmd
                |> inFinishedPage


inPage : (pageModel -> Model) -> (pageMsg -> Msg) -> ( pageModel, Cmd pageMsg ) -> ( Model, Cmd Msg )
inPage toModel toMsg ( pageModel, pageCmd ) =
    ( toModel pageModel, Cmd.map toMsg pageCmd )


inSetupPage : ( Setup.Model, Cmd Setup.Msg ) -> ( Model, Cmd Msg )
inSetupPage =
    inPage SetupPage SetupMsg


inPathfindingPage : ( Pathfinding.Model, Cmd Pathfinding.Msg ) -> ( Model, Cmd Msg )
inPathfindingPage =
    inPage PathfindingPage PathfindingMsg


inFinishedPage : ( Finished.Model, Cmd Msg ) -> ( Model, Cmd Msg )
inFinishedPage =
    inPage FinishedPage identity


initSetup : ( Model, Cmd Msg )
initSetup =
    inSetupPage Setup.init


initSetupWithSourceAndDestination : Title -> Title -> ( Model, Cmd Msg )
initSetupWithSourceAndDestination source destination =
    Setup.initWithTitles source destination |> inSetupPage



-- View


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
        SetupPage model ->
            Setup.view model |> StyledHtml.map SetupMsg

        PathfindingPage model ->
            Pathfinding.view model |> StyledHtml.map PathfindingMsg

        FinishedPage model ->
            Finished.view model BackToSetup



-- Main


main : Program Never Model Msg
main =
    Html.program
        { init = initSetup
        , view = view >> toUnstyled
        , update = update
        , subscriptions = \_ -> Sub.none
        }
