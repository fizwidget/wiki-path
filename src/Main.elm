module Main exposing (main)

import Article exposing (Article, Full)
import Browser exposing (Document)
import Css exposing (..)
import Css.Media as Media exposing (withMedia)
import Html
import Html.Styled as StyledHtml exposing (Html, div, h1, text, toUnstyled)
import Html.Styled.Attributes as Attributes exposing (css)
import Page.Finished as Finished
import Page.Pathfinding as Pathfinding
import Page.Setup as Setup



-- MODEL


type Model
    = SetupModel Setup.Model
    | PathfindingModel Pathfinding.Model
    | FinishedModel Finished.Model



-- UPDATE


type Msg
    = SetupMsg Setup.Msg
    | PathfindingMsg Pathfinding.Msg
    | FinishedMsg Finished.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( SetupMsg subMsg, SetupModel subModel ) ->
            Setup.update subMsg subModel
                |> handleSetupUpdate

        ( PathfindingMsg subMsg, PathfindingModel subModel ) ->
            Pathfinding.update subMsg subModel
                |> handlePathfindingUpdate

        ( FinishedMsg subMsg, FinishedModel subModel ) ->
            Finished.update subMsg subModel
                |> handleFinishedUpdate

        ( _, _ ) ->
            ( model, Cmd.none )


handleSetupUpdate : Setup.UpdateResult -> ( Model, Cmd Msg )
handleSetupUpdate updateResult =
    case updateResult of
        Setup.InProgress ( model, cmd ) ->
            inSetupPage ( model, cmd )

        Setup.Complete source destination ->
            Pathfinding.init source destination
                |> handlePathfindingUpdate


handlePathfindingUpdate : Pathfinding.UpdateResult -> ( Model, Cmd Msg )
handlePathfindingUpdate updateResult =
    case updateResult of
        Pathfinding.InProgress ( model, cmd ) ->
            inPathfindingPage ( model, cmd )

        Pathfinding.Cancelled source destination ->
            Setup.initWithArticles source destination
                |> inSetupPage

        Pathfinding.Complete path ->
            Finished.initWithPath path
                |> noCmd
                |> inFinishedPage

        Pathfinding.PathNotFound source destination ->
            Finished.initWithPathNotFoundError (Article.preview source) (Article.preview destination)
                |> noCmd
                |> inFinishedPage

        Pathfinding.TooManyRequests source destination ->
            Finished.initWithTooManyRequestsError (Article.preview source) (Article.preview destination)
                |> noCmd
                |> inFinishedPage


handleFinishedUpdate : Finished.UpdateResult -> ( Model, Cmd Msg )
handleFinishedUpdate (Finished.BackToSetup source destination) =
    Setup.initWithArticles (Article.preview source) (Article.preview destination)
        |> inSetupPage


inSetupPage : ( Setup.Model, Cmd Setup.Msg ) -> ( Model, Cmd Msg )
inSetupPage =
    inPage SetupModel SetupMsg


inPathfindingPage : ( Pathfinding.Model, Cmd Pathfinding.Msg ) -> ( Model, Cmd Msg )
inPathfindingPage =
    inPage PathfindingModel PathfindingMsg


inFinishedPage : ( Finished.Model, Cmd Finished.Msg ) -> ( Model, Cmd Msg )
inFinishedPage =
    inPage FinishedModel FinishedMsg


inPage : (subModel -> model) -> (subMsg -> msg) -> ( subModel, Cmd subMsg ) -> ( model, Cmd msg )
inPage toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )


noCmd : model -> ( model, Cmd msg )
noCmd model =
    ( model, Cmd.none )



-- VIEW


document : Model -> Document Msg
document model =
    { title = "WikiPath"
    , body = [ view model |> toUnstyled ]
    }


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
        SetupModel subModel ->
            Setup.view subModel
                |> StyledHtml.map SetupMsg

        PathfindingModel subModel ->
            Pathfinding.view subModel
                |> StyledHtml.map PathfindingMsg

        FinishedModel subModel ->
            Finished.view subModel
                |> StyledHtml.map FinishedMsg



-- MAIN


main : Program () Model Msg
main =
    Browser.document
        { init = \_ -> inSetupPage Setup.init
        , view = document
        , update = update
        , subscriptions = always Sub.none
        }
