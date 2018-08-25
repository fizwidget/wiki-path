module Page.Setup
    exposing
        ( Model
        , Msg
        , UpdateResult(InProgress, Complete)
        , init
        , initWithTitles
        , update
        , view
        )

import Html.Styled exposing (Html, fromUnstyled, toUnstyled, div, pre, input, button, text, form)
import Html.Styled.Attributes exposing (css, value, type_, placeholder)
import Css exposing (..)
import Bootstrap.Button as ButtonOptions
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import RemoteData exposing (WebData, RemoteData(Loading, NotAsked))
import Request.Article as Article exposing (RemoteArticle)
import Request.Title as Title exposing (RemoteTitlePair)
import Data.Article exposing (Article)
import Data.Title as Title exposing (Title)
import View.Button as Button
import View.ArticleError as ArticleError
import View.Spinner as Spinner


-- MODEL


type alias Model =
    { sourceInput : UserInput
    , destinationInput : UserInput
    , source : RemoteArticle
    , destination : RemoteArticle
    , randomTitles : RemoteTitlePair
    }


type alias UserInput =
    String



-- INIT


init : ( Model, Cmd Msg )
init =
    ( initialModel "" "", Cmd.none )


initWithTitles : Title -> Title -> ( Model, Cmd Msg )
initWithTitles source destination =
    ( initialModel (Title.asString source) (Title.asString destination)
    , Cmd.none
    )


initialModel : String -> String -> Model
initialModel sourceInput destinationInput =
    { sourceInput = sourceInput
    , destinationInput = destinationInput
    , source = NotAsked
    , destination = NotAsked
    , randomTitles = NotAsked
    }



-- UPDATE


type Msg
    = SourceInputChange UserInput
    | DestinationInputChange UserInput
    | GetArticlesRequest
    | GetSourceArticleResponse RemoteArticle
    | GetDestinationArticleResponse RemoteArticle
    | RandomizeTitlesRequest
    | RandomizeTitlesResponse RemoteTitlePair


type UpdateResult
    = InProgress ( Model, Cmd Msg )
    | Complete Article Article


update : Msg -> Model -> UpdateResult
update msg model =
    case msg of
        SourceInputChange title ->
            { model | sourceInput = title, source = NotAsked }
                |> noCmd
                |> InProgress

        DestinationInputChange title ->
            { model | destinationInput = title, destination = NotAsked }
                |> noCmd
                |> InProgress

        RandomizeTitlesRequest ->
            ( { model | randomTitles = Loading }, Title.getRandomPair RandomizeTitlesResponse )
                |> InProgress

        RandomizeTitlesResponse response ->
            { model | randomTitles = response }
                |> displayRandomTitles
                |> noCmd
                |> InProgress

        GetArticlesRequest ->
            ( { model | source = Loading, destination = Loading }, getArticles model )
                |> InProgress

        GetSourceArticleResponse article ->
            { model | source = article }
                |> maybeComplete

        GetDestinationArticleResponse article ->
            { model | destination = article }
                |> maybeComplete


getArticles : Model -> Cmd Msg
getArticles { sourceInput, destinationInput } =
    Cmd.batch <|
        [ Article.getRemoteArticle GetSourceArticleResponse sourceInput
        , Article.getRemoteArticle GetDestinationArticleResponse destinationInput
        ]


maybeComplete : Model -> UpdateResult
maybeComplete ({ source, destination } as model) =
    RemoteData.map2 Complete source destination
        |> RemoteData.withDefault (model |> noCmd |> InProgress)


displayRandomTitles : Model -> Model
displayRandomTitles model =
    let
        setInputFields ( source, destination ) =
            { model
                | source = NotAsked
                , destination = NotAsked
                , sourceInput = Title.asString source
                , destinationInput = Title.asString destination
            }
    in
        model.randomTitles
            |> RemoteData.map setInputFields
            |> RemoteData.withDefault model


noCmd : model -> ( model, Cmd msg )
noCmd model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    form
        [ css [ displayFlex, alignItems center, flexDirection column ] ]
        [ viewTitleInputs model
        , viewFindPathButton model
        , viewRandomizeTitlesButton model
        , viewTitleRandomizationError model.randomTitles
        , viewLoadingSpinner model
        ]


viewTitleInputs : Model -> Html Msg
viewTitleInputs ({ sourceInput, destinationInput, source, destination } as model) =
    div [ css [ displayFlex, justifyContent center, flexWrap wrap ] ]
        [ viewSourceTitleInput sourceInput source (getInputStatus model)
        , viewDestinationTitleInput destinationInput destination (getInputStatus model)
        ]


getInputStatus : Model -> InputStatus
getInputStatus model =
    if isLoading model then
        Disabled
    else
        Enabled


viewSourceTitleInput : UserInput -> RemoteArticle -> InputStatus -> Html Msg
viewSourceTitleInput =
    viewTitleInput SourceInputChange "From..."


viewDestinationTitleInput : UserInput -> RemoteArticle -> InputStatus -> Html Msg
viewDestinationTitleInput =
    viewTitleInput DestinationInputChange "To..."


viewTitleInput : (UserInput -> Msg) -> String -> UserInput -> RemoteArticle -> InputStatus -> Html Msg
viewTitleInput toMsg placeholder title article inputStatus =
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
                   , Input.placeholder placeholder
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
            , ButtonOptions.onClick GetArticlesRequest
            ]
            [ text "Find path" ]
        ]


viewRandomizeTitlesButton : Model -> Html Msg
viewRandomizeTitlesButton model =
    div [ css [ padding (px 12) ] ]
        [ Button.view
            [ ButtonOptions.light
            , ButtonOptions.large
            , ButtonOptions.disabled (isLoading model)
            , ButtonOptions.onClick RandomizeTitlesRequest
            ]
            [ text "Randomize" ]
        ]


shouldDisableLoadButton : Model -> Bool
shouldDisableLoadButton model =
    isLoading model
        || isBlank model.sourceInput
        || isBlank model.destinationInput


isBlank : String -> Bool
isBlank =
    String.trim >> String.isEmpty


viewLoadingSpinner : Model -> Html msg
viewLoadingSpinner model =
    div
        [ css [ paddingTop (px 6) ] ]
        [ Spinner.view { isVisible = isLoading model } ]


isLoading : Model -> Bool
isLoading { source, destination, randomTitles } =
    let
        areArticlesLoading =
            List.any RemoteData.isLoading [ source, destination ]

        areTitlesLoading =
            RemoteData.isLoading randomTitles
    in
        areArticlesLoading || areTitlesLoading


viewArticleError : RemoteArticle -> Html msg
viewArticleError remoteArticle =
    case remoteArticle of
        RemoteData.Failure error ->
            ArticleError.view error

        _ ->
            text ""


viewTitleRandomizationError : RemoteTitlePair -> Html msg
viewTitleRandomizationError randomTitles =
    if RemoteData.isFailure randomTitles then
        text "Sorry, an error occured 😵"
    else
        text ""


type InputStatus
    = Enabled
    | Disabled
