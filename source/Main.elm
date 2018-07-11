module Main exposing (main)

import Css exposing (..)
import Html as CoreHtml
import Html.Styled as Html exposing (Html, toUnstyled, div, h1, text)
import Html.Styled.Attributes as Attributes exposing (css)
import Page.Finished as Finished
import Page.Pathfinding as Pathfinding
import Page.Setup as Setup


-- MAIN --


main : Program Never Model Msg
main =
    CoreHtml.program
        { init = initSetup
        , view = view >> toUnstyled
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL --


type Model
    = SetupPage Setup.Model
    | PathfindingPage Pathfinding.Model
    | FinishedPage Finished.Model



-- MESSAGES --


type Msg
    = SetupMsg Setup.Msg
    | PathfindingMsg Pathfinding.Msg
    | BackToSetup



-- UPDATE --


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case ( message, model ) of
        ( BackToSetup, _ ) ->
            initSetup

        ( SetupMsg innerMsg, SetupPage innerModel ) ->
            Setup.update innerMsg innerModel |> onSetupUpdate

        ( PathfindingMsg innerMsg, PathfindingPage innerModel ) ->
            Pathfinding.update innerMsg innerModel |> onPathfindingUpdate

        ( _, _ ) ->
            ( model, Cmd.none )


initSetup : ( Model, Cmd Msg )
initSetup =
    inPage SetupPage SetupMsg Setup.init


inPage : (a -> Model) -> (b -> Msg) -> ( a, Cmd b ) -> ( Model, Cmd Msg )
inPage toModel toMsg ( model, cmd ) =
    ( toModel model, Cmd.map toMsg cmd )


onSetupUpdate : Setup.UpdateResult -> ( Model, Cmd Msg )
onSetupUpdate updateResult =
    case updateResult of
        Setup.InSetup ( model, cmd ) ->
            ( SetupPage model, Cmd.map SetupMsg cmd )

        Setup.Done source destination ->
            Pathfinding.init source destination |> onPathfindingUpdate


onPathfindingUpdate : Pathfinding.UpdateResult -> ( Model, Cmd Msg )
onPathfindingUpdate updateResult =
    case updateResult of
        Pathfinding.InPathfinding ( model, cmd ) ->
            ( PathfindingPage model, Cmd.map PathfindingMsg cmd )

        Pathfinding.Done pathToDestination ->
            ( FinishedPage <| Finished.Success pathToDestination, Cmd.none )

        Pathfinding.Back ->
            initSetup

        Pathfinding.PathNotFound source destination ->
            ( FinishedPage <| Finished.Error { error = Finished.PathNotFound, source = source, destination = destination }, Cmd.none )

        Pathfinding.TooManyRequests source destination ->
            ( FinishedPage <| Finished.Error { error = Finished.TooManyRequests, source = source, destination = destination }, Cmd.none )



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
        SetupPage innerModel ->
            Setup.view innerModel
                |> Html.map SetupMsg

        PathfindingPage innerModel ->
            Pathfinding.view innerModel
                |> Html.map PathfindingMsg

        FinishedPage path ->
            Finished.view path BackToSetup
