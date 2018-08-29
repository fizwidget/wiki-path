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
import RemoteData exposing (WebData, RemoteData(Loading, NotAsked))
import Article exposing (Article, Preview, Full, RemoteArticle, RemoteTitlePair)
import Button
import Input
import Form
import Spinner


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


initWithTitles : Article Preview -> Article Preview -> ( Model, Cmd Msg )
initWithTitles source destination =
    ( initialModel (Article.title source) (Article.title destination)
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
    | Complete (Article Full) (Article Full)


update : Msg -> Model -> UpdateResult
update msg model =
    case msg of
        SourceInputChange input ->
            { model | sourceInput = input, source = NotAsked }
                |> noCmd
                |> InProgress

        DestinationInputChange input ->
            { model | destinationInput = input, destination = NotAsked }
                |> noCmd
                |> InProgress

        RandomizeTitlesRequest ->
            ( { model | randomTitles = Loading }, Article.getRandomPair RandomizeTitlesResponse )
                |> InProgress

        RandomizeTitlesResponse response ->
            { model | randomTitles = response }
                |> randomizeTitleInputs
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


maybeComplete : Model -> UpdateResult
maybeComplete ({ source, destination } as model) =
    RemoteData.map2 Complete source destination
        |> RemoteData.withDefault (model |> noCmd |> InProgress)


getArticles : Model -> Cmd Msg
getArticles { sourceInput, destinationInput } =
    Cmd.batch <|
        [ Article.getRemoteArticle GetSourceArticleResponse sourceInput
        , Article.getRemoteArticle GetDestinationArticleResponse destinationInput
        ]


randomizeTitleInputs : Model -> Model
randomizeTitleInputs model =
    let
        setTitleInputs ( source, destination ) =
            { model
                | source = NotAsked
                , destination = NotAsked
                , sourceInput = Article.title source
                , destinationInput = Article.title destination
            }
    in
        model.randomTitles
            |> RemoteData.map setTitleInputs
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
        , viewRandomizeTitlesButton (isLoading model)
        , viewTitleRandomizationError model.randomTitles
        , viewLoadingSpinner (isLoading model)
        ]


viewTitleInputs : Model -> Html Msg
viewTitleInputs ({ sourceInput, destinationInput, source, destination } as model) =
    div [ css [ displayFlex, justifyContent center, flexWrap wrap ] ]
        [ viewSourceTitleInput sourceInput source (isLoading model)
        , viewDestinationTitleInput destinationInput destination (isLoading model)
        ]


viewSourceTitleInput : UserInput -> RemoteArticle -> Bool -> Html Msg
viewSourceTitleInput =
    viewTitleInput SourceInputChange "From..."


viewDestinationTitleInput : UserInput -> RemoteArticle -> Bool -> Html Msg
viewDestinationTitleInput =
    viewTitleInput DestinationInputChange "To..."


viewTitleInput : (UserInput -> Msg) -> String -> String -> RemoteArticle -> Bool -> Html Msg
viewTitleInput toMsg placeholder title article isDisabled =
    div [ css [ padding2 (px 0) (px 8), height (px 76) ] ]
        [ Form.group
            (Input.text
                [ Input.Large
                , Input.OnInput toMsg
                , Input.Value title
                , Input.Placeholder placeholder
                , Input.Disabled isDisabled
                , Input.Error (RemoteData.isFailure article)
                ]
            )
            (viewArticleError article)
        ]


viewFindPathButton : Model -> Html Msg
viewFindPathButton model =
    div [ css [ padding (px 4) ] ]
        [ Button.view "Find path"
            [ Button.Primary
            , Button.Large
            , Button.Disabled (shouldDisableLoadButton model)
            , Button.OnClick GetArticlesRequest
            ]
        ]


viewRandomizeTitlesButton : Bool -> Html Msg
viewRandomizeTitlesButton isDisabled =
    div [ css [ padding (px 12) ] ]
        [ Button.view "Randomize"
            [ Button.Light
            , Button.Large
            , Button.Disabled isDisabled
            , Button.OnClick RandomizeTitlesRequest
            ]
        ]


viewArticleError : RemoteArticle -> Html msg
viewArticleError remoteArticle =
    case remoteArticle of
        RemoteData.Failure error ->
            Article.viewError error

        _ ->
            text ""


viewTitleRandomizationError : RemoteTitlePair -> Html msg
viewTitleRandomizationError randomTitles =
    if RemoteData.isFailure randomTitles then
        text "Sorry, an error occured 😵"
    else
        text ""


viewLoadingSpinner : Bool -> Html msg
viewLoadingSpinner isVisible =
    div
        [ css [ paddingTop (px 6) ] ]
        [ Spinner.view { isVisible = isVisible } ]


shouldDisableLoadButton : Model -> Bool
shouldDisableLoadButton model =
    isLoading model
        || isBlank model.sourceInput
        || isBlank model.destinationInput


isBlank : String -> Bool
isBlank =
    String.trim >> String.isEmpty


isLoading : Model -> Bool
isLoading { source, destination, randomTitles } =
    let
        areArticlesLoading =
            List.any RemoteData.isLoading [ source, destination ]

        areTitlesLoading =
            RemoteData.isLoading randomTitles
    in
        areArticlesLoading || areTitlesLoading
