module Page.Setup
    exposing
        ( Model
        , Msg
        , UpdateResult(Continue, Done)
        , init
        , initWithTitles
        , update
        , view
        )

import Bootstrap.Button as ButtonOptions
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Common.Article as Fetch
import Common.Article exposing (Article, RemoteArticle, ArticleError(..))
import Common.Article as Article
import Common.Button as Button
import Common.Error as Error
import Common.Spinner as Spinner
import Common.Title as Title exposing (Title, RemoteTitlePair)
import Css exposing (..)
import Html.Styled exposing (Html, fromUnstyled, toUnstyled, div, pre, input, button, text, form)
import Html.Styled.Attributes exposing (css, value, type_, placeholder)
import RemoteData exposing (WebData, RemoteData(Loading, NotAsked))


-- MODEL --


type alias Model =
    { sourceTitleInput : UserInput
    , destinationTitleInput : UserInput
    , source : RemoteArticle
    , destination : RemoteArticle
    , randomTitles : RemoteTitlePair
    }


type alias UserInput =
    String



-- INIT --


init : ( Model, Cmd Msg )
init =
    ( initialModel "" "", Cmd.none )


initWithTitles : Title -> Title -> ( Model, Cmd Msg )
initWithTitles source destination =
    ( initialModel (Title.value source) (Title.value destination)
    , Cmd.none
    )


initialModel : String -> String -> Model
initialModel sourceTitleInput destinationTitleInput =
    { sourceTitleInput = sourceTitleInput
    , destinationTitleInput = destinationTitleInput
    , source = NotAsked
    , destination = NotAsked
    , randomTitles = NotAsked
    }



-- UPDATE --


type Msg
    = SourceArticleTitleChange UserInput
    | DestinationArticleTitleChange UserInput
    | FetchArticlesRequest
    | FetchSourceArticleResponse RemoteArticle
    | FetchDestinationArticleResponse RemoteArticle
    | FetchRandomTitlesRequest
    | FetchRandomTitlesResponse RemoteTitlePair


type UpdateResult
    = Continue ( Model, Cmd Msg )
    | Done Article Article


update : Msg -> Model -> UpdateResult
update message model =
    case message of
        SourceArticleTitleChange value ->
            { model | sourceTitleInput = value, source = NotAsked }
                |> noMsg
                |> Continue

        DestinationArticleTitleChange value ->
            { model | destinationTitleInput = value, destination = NotAsked }
                |> noMsg
                |> Continue

        FetchRandomTitlesRequest ->
            ( { model | randomTitles = Loading }, Title.fetchPair FetchRandomTitlesResponse )
                |> Continue

        FetchRandomTitlesResponse response ->
            { model | randomTitles = response }
                |> randomizeInputFields
                |> noMsg
                |> Continue

        FetchArticlesRequest ->
            ( { model | source = Loading, destination = Loading }, fetchArticles model )
                |> Continue

        FetchSourceArticleResponse article ->
            { model | source = article }
                |> maybeBeginPathfinding

        FetchDestinationArticleResponse article ->
            { model | destination = article }
                |> maybeBeginPathfinding


fetchArticles : Model -> Cmd Msg
fetchArticles model =
    Cmd.batch <|
        [ Article.fetchRemoteArticle FetchSourceArticleResponse model.sourceTitleInput
        , Article.fetchRemoteArticle FetchDestinationArticleResponse model.destinationTitleInput
        ]


maybeBeginPathfinding : Model -> UpdateResult
maybeBeginPathfinding model =
    let
        sourceAndDestination =
            RemoteData.toMaybe <| RemoteData.map2 (,) model.source model.destination
    in
        case sourceAndDestination of
            Just ( source, destination ) ->
                Done source destination

            Nothing ->
                model |> noMsg |> Continue


randomizeInputFields : Model -> Model
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


noMsg : Model -> ( Model, Cmd Msg )
noMsg model =
    ( model, Cmd.none )



-- VIEW --


view : Model -> Html Msg
view model =
    form
        [ css [ displayFlex, alignItems center, flexDirection column ] ]
        [ viewTitleInputs model
        , viewFindPathButton model
        , viewRandomizeTitlesButton model
        , viewRandomizationError model
        , viewLoadingSpinner model
        ]


viewTitleInputs : Model -> Html Msg
viewTitleInputs ({ sourceTitleInput, destinationTitleInput, source, destination } as model) =
    let
        inputStatus =
            if isLoading model then
                Disabled
            else
                Enabled
    in
        div [ css [ displayFlex, justifyContent center, flexWrap wrap ] ]
            [ viewSourceTitleInput sourceTitleInput source inputStatus
            , viewDestinationTitleInput destinationTitleInput destination inputStatus
            ]


viewSourceTitleInput : UserInput -> RemoteArticle -> InputStatus -> Html Msg
viewSourceTitleInput =
    articleTitleInput "From..." SourceArticleTitleChange


viewDestinationTitleInput : UserInput -> RemoteArticle -> InputStatus -> Html Msg
viewDestinationTitleInput =
    articleTitleInput "To..." DestinationArticleTitleChange


articleTitleInput : String -> (UserInput -> Msg) -> UserInput -> RemoteArticle -> InputStatus -> Html Msg
articleTitleInput placeholderText toMsg title article inputStatus =
    let
        isDisabled =
            case inputStatus of
                Enabled ->
                    False

                Disabled ->
                    True

        inputStyle =
            if RemoteData.isFailure article then
                [ Input.danger ]
            else
                []

        inputOptions =
            inputStyle
                ++ [ Input.large
                   , Input.onInput toMsg
                   , Input.value title
                   , Input.placeholder placeholderText
                   , Input.disabled isDisabled
                   ]
    in
        div [ css [ padding2 (px 0) (px 8), height (px 76) ] ]
            [ fromUnstyled <|
                Form.group []
                    [ Input.text inputOptions
                    , Form.invalidFeedback [] [ toUnstyled <| viewArticleError article ]
                    , Form.validFeedback [] []
                    ]
            ]


viewFindPathButton : Model -> Html Msg
viewFindPathButton model =
    div [ css [ padding (px 4) ] ]
        [ Button.view
            [ ButtonOptions.primary
            , ButtonOptions.large
            , ButtonOptions.disabled (shouldDisableLoadButton model)
            , ButtonOptions.onClick FetchArticlesRequest
            ]
            [ text "Find path" ]
        ]


viewRandomizeTitlesButton : Model -> Html Msg
viewRandomizeTitlesButton model =
    div [ css [ padding (px 12) ] ]
        [ Button.view
            [ ButtonOptions.large
            , ButtonOptions.light
            , ButtonOptions.disabled (isLoading model)
            , ButtonOptions.onClick FetchRandomTitlesRequest
            ]
            [ text "Randomize" ]
        ]


shouldDisableLoadButton : Model -> Bool
shouldDisableLoadButton model =
    let
        isBlank =
            String.trim >> String.isEmpty
    in
        isLoading model
            || isBlank model.sourceTitleInput
            || isBlank model.destinationTitleInput


viewLoadingSpinner : Model -> Html msg
viewLoadingSpinner model =
    div
        [ css [ paddingTop (px 6) ] ]
        [ Spinner.view { isVisible = isLoading model } ]


isLoading : Model -> Bool
isLoading { source, destination, randomTitles } =
    let
        areArticlesLoading =
            [ source, destination ]
                |> RemoteData.fromList
                |> RemoteData.isLoading

        areTitlesLoading =
            RemoteData.isLoading randomTitles
    in
        areArticlesLoading || areTitlesLoading


viewArticleError : RemoteArticle -> Html msg
viewArticleError remoteArticle =
    case remoteArticle of
        RemoteData.Failure error ->
            Article.viewError error

        _ ->
            text ""


viewRandomizationError : Model -> Html msg
viewRandomizationError { randomTitles } =
    case randomTitles of
        RemoteData.Failure error ->
            Error.view "Error randomizing titles 😵" (toString error)

        _ ->
            text ""


type InputStatus
    = Enabled
    | Disabled
