module Main exposing (main)

import Html
import Html.Styled as StyledHtml exposing (Html, toUnstyled, div, h1, text)
import Html.Styled.Attributes as Attributes exposing (css)
import Css exposing (..)
import Css.Media as Media exposing (withMedia)
import Util exposing (noCmd)
import Page.Finished as Finished
import Page.Pathfinding as Pathfinding
import Page.Setup as Setup
import Data.Title exposing (Title)


-- MODEL


type Model
    = SetupPage Setup.Model
    | PathfindingPage Pathfinding.Model
    | FinishedPage Finished.Model



-- UPDATE


type Msg
    = SetupMsg Setup.Msg
    | PathfindingMsg Pathfinding.Msg
    | BackToSetup Title Title


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( BackToSetup source destination, _ ) ->
            initSetupWithTitles source destination

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
            initSetupWithTitles source.title destination.title

        Pathfinding.PathFound path ->
            Finished.initWithPath path
                |> noCmd
                |> inFinishedPage

        Pathfinding.PathNotFound source destination ->
            Finished.initWithPathNotFoundError source destination
                |> noCmd
                |> inFinishedPage

        Pathfinding.TooManyRequests source destination ->
            Finished.initWithTooManyRequestsError source destination
                |> noCmd
                |> inFinishedPage


inSetupPage : ( Setup.Model, Cmd Setup.Msg ) -> ( Model, Cmd Msg )
inSetupPage =
    inPage SetupPage SetupMsg


inPathfindingPage : ( Pathfinding.Model, Cmd Pathfinding.Msg ) -> ( Model, Cmd Msg )
inPathfindingPage =
    inPage PathfindingPage PathfindingMsg


inFinishedPage : ( Finished.Model, Cmd msg ) -> ( Model, Cmd msg )
inFinishedPage =
    inPage FinishedPage identity


inPage : (pageModel -> model) -> (pageMsg -> msg) -> ( pageModel, Cmd pageMsg ) -> ( model, Cmd msg )
inPage toModel toMsg ( pageModel, pageCmd ) =
    ( toModel pageModel, Cmd.map toMsg pageCmd )


initSetup : ( Model, Cmd Msg )
initSetup =
    inSetupPage Setup.init


initSetupWithTitles : Title -> Title -> ( Model, Cmd Msg )
initSetupWithTitles source destination =
    Setup.initWithTitles source destination |> inSetupPage



-- VIEW


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
    let
        desktopFontSize =
            fontSize (px 80)

        mobileFontStyle =
            withMedia
                [ Media.all [ Media.maxWidth (px 420) ] ]
                [ fontSize (vw 20) ]
    in
        h1
            [ css
                [ desktopFontSize
                , mobileFontStyle
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
            Setup.view model
                |> StyledHtml.map SetupMsg

        PathfindingPage model ->
            Pathfinding.view model
                |> StyledHtml.map PathfindingMsg

        FinishedPage model ->
            Finished.view model BackToSetup



-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = initSetup
        , view = view >> toUnstyled
        , update = update
        , subscriptions = \_ -> Sub.none
        }
