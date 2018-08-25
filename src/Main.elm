module Main exposing (main)

import Html
import Html.Styled as StyledHtml exposing (Html, toUnstyled, div, h1, text)
import Html.Styled.Attributes as Attributes exposing (css)
import Css exposing (..)
import Css.Media as Media exposing (withMedia)
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
update msg model =
    case ( msg, model ) of
        ( SetupMsg subMsg, SetupPage subModel ) ->
            Setup.update subMsg subModel
                |> handleSetupUpdate

        ( PathfindingMsg subMsg, PathfindingPage subModel ) ->
            Pathfinding.update subMsg subModel
                |> handlePathfindingUpdate

        ( BackToSetup source destination, _ ) ->
            Setup.initWithTitles source destination
                |> inSetupPage

        ( _, _ ) ->
            ( model, Cmd.none )


handleSetupUpdate : Setup.UpdateResult -> ( Model, Cmd Msg )
handleSetupUpdate updateResult =
    case updateResult of
        Setup.Continue ( model, cmd ) ->
            inSetupPage ( model, cmd )

        Setup.Done source destination ->
            Pathfinding.init source destination
                |> handlePathfindingUpdate


handlePathfindingUpdate : Pathfinding.UpdateResult -> ( Model, Cmd Msg )
handlePathfindingUpdate updateResult =
    case updateResult of
        Pathfinding.Continue ( model, cmd ) ->
            inPathfindingPage ( model, cmd )

        Pathfinding.Cancel source destination ->
            Setup.initWithTitles source.title destination.title
                |> inSetupPage

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


inPage : (subModel -> model) -> (subMsg -> msg) -> ( subModel, Cmd subMsg ) -> ( model, Cmd msg )
inPage toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )


noCmd : model -> ( model, Cmd msg )
noCmd model =
    ( model, Cmd.none )



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
        { init = Setup.init |> inSetupPage
        , view = view >> toUnstyled
        , update = update
        , subscriptions = always Sub.none
        }
