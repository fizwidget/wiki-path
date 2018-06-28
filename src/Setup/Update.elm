module Setup.Update exposing (update)

import RemoteData exposing (WebData, RemoteData(Loading, NotAsked))
import Common.Title.Model as Title exposing (Title, RemoteTitlePair)
import Common.Title.Fetch as Fetch
import Common.Article.Fetch as Fetch
import Model exposing (Model)
import Messages exposing (Msg)
import Setup.Messages exposing (SetupMsg(..))
import Setup.Model exposing (SetupModel, UserInput)
import Pathfinding.Init


update : SetupMsg -> SetupModel -> ( Model, Cmd Msg )
update message model =
    case message of
        SourceArticleTitleChange value ->
            { model | sourceTitleInput = value, source = NotAsked }
                |> noMsg
                |> inSetupPage

        DestinationArticleTitleChange value ->
            { model | destinationTitleInput = value, destination = NotAsked }
                |> noMsg
                |> inSetupPage

        FetchRandomTitlesRequest ->
            ( { model | randomTitles = Loading }, Fetch.titlePair FetchRandomTitlesResponse )
                |> inSetupPage

        FetchRandomTitlesResponse response ->
            { model | randomTitles = response }
                |> randomizeInputFields
                |> noMsg
                |> inSetupPage

        FetchArticlesRequest ->
            ( { model | source = Loading, destination = Loading }, fetchArticles model )
                |> inSetupPage

        FetchSourceArticleResponse article ->
            { model | source = article }
                |> maybeBeginPathfinding

        FetchDestinationArticleResponse article ->
            { model | destination = article }
                |> maybeBeginPathfinding


fetchArticles : SetupModel -> Cmd SetupMsg
fetchArticles model =
    Cmd.batch <|
        [ Fetch.remoteArticle FetchSourceArticleResponse model.sourceTitleInput
        , Fetch.remoteArticle FetchDestinationArticleResponse model.destinationTitleInput
        ]


maybeBeginPathfinding : SetupModel -> ( Model, Cmd Msg )
maybeBeginPathfinding model =
    let
        sourceAndDestination =
            RemoteData.toMaybe <| RemoteData.map2 (,) model.source model.destination
    in
        case sourceAndDestination of
            Just ( source, destination ) ->
                Pathfinding.Init.init source destination

            Nothing ->
                model |> noMsg |> inSetupPage


randomizeInputFields : SetupModel -> SetupModel
randomizeInputFields model =
    let
        setInputFields ( source, destination ) =
            { model
                | source = NotAsked
                , destination = NotAsked
                , sourceTitleInput = Title.value source
                , destinationTitleInput = Title.value destination
            }
    in
        model.randomTitles
            |> RemoteData.map setInputFields
            |> RemoteData.withDefault model


noMsg : SetupModel -> ( SetupModel, Cmd SetupMsg )
noMsg model =
    ( model, Cmd.none )


inSetupPage : ( SetupModel, Cmd SetupMsg ) -> ( Model, Cmd Msg )
inSetupPage ( model, cmd ) =
    ( Model.Setup model, Cmd.map Messages.Setup cmd )
