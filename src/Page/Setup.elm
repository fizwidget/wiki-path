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

import Html.Styled exposing (Html, fromUnstyled, toUnstyled, div, pre, input, button, text, form)
import Html.Styled.Attributes exposing (css, value, type_, placeholder)
import Css exposing (..)
import Bootstrap.Button as ButtonOptions
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import RemoteData exposing (WebData, RemoteData(Loading, NotAsked))
import Util exposing (noCmd)
import Request.Article as Article exposing (RemoteArticle)
import Request.Title as Title exposing (RemoteTitlePair)
import Data.Article exposing (Article)
import Data.Title as Title exposing (Title)
import View.Button as Button
import View.Error as Error
import View.Spinner as Spinner


-- MODEL


type alias Model =
    { sourceTitle : UserInput
    , destinationTitle : UserInput
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
    ( initialModel (Title.value source) (Title.value destination)
    , Cmd.none
    )


initialModel : String -> String -> Model
initialModel sourceTitle destinationTitle =
    { sourceTitle = sourceTitle
    , destinationTitle = destinationTitle
    , source = NotAsked
    , destination = NotAsked
    , randomTitles = NotAsked
    }



-- UPDATE


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
update msg model =
    case msg of
        SourceArticleTitleChange title ->
            { model | sourceTitle = title, source = NotAsked }
                |> noCmd
                |> Continue

        DestinationArticleTitleChange title ->
            { model | destinationTitle = title, destination = NotAsked }
                |> noCmd
                |> Continue

        FetchRandomTitlesRequest ->
            ( { model | randomTitles = Loading }, Title.fetchPair FetchRandomTitlesResponse )
                |> Continue

        FetchRandomTitlesResponse response ->
            { model | randomTitles = response }
                |> displayRandomTitles
                |> noCmd
                |> Continue

        FetchArticlesRequest ->
            ( { model | source = Loading, destination = Loading }, fetchArticles model )
                |> Continue

        FetchSourceArticleResponse article ->
            { model | source = article }
                |> doneIfBothLoaded

        FetchDestinationArticleResponse article ->
            { model | destination = article }
                |> doneIfBothLoaded


fetchArticles : Model -> Cmd Msg
fetchArticles { sourceTitle, destinationTitle } =
    Cmd.batch <|
        [ Article.fetchRemoteArticle FetchSourceArticleResponse sourceTitle
        , Article.fetchRemoteArticle FetchDestinationArticleResponse destinationTitle
        ]


doneIfBothLoaded : Model -> UpdateResult
doneIfBothLoaded ({ source, destination } as model) =
    RemoteData.map2 Done source destination
        |> RemoteData.withDefault (model |> noCmd |> Continue)


displayRandomTitles : Model -> Model
displayRandomTitles model =
    let
        setInputFields ( source, destination ) =
            { model
                | source = NotAsked
                , destination = NotAsked
                , sourceTitle = Title.value source
                , destinationTitle = Title.value destination
            }
    in
        model.randomTitles
            |> RemoteData.map setInputFields
            |> RemoteData.withDefault model



-- VIEW


view : Model -> Html Msg
view model =
    form
        [ css [ displayFlex, alignItems center, flexDirection column ] ]
        [ viewTitleInputs model
        , viewFindPathButton model
        , viewRandomizeTitlesButton model
        , viewRandomizeTitlesError model
        , viewLoadingSpinner model
        ]


viewTitleInputs : Model -> Html Msg
viewTitleInputs ({ sourceTitle, destinationTitle, source, destination } as model) =
    div [ css [ displayFlex, justifyContent center, flexWrap wrap ] ]
        [ viewSourceTitleInput sourceTitle source (getInputStatus model)
        , viewDestinationTitleInput destinationTitle destination (getInputStatus model)
        ]


getInputStatus : Model -> InputStatus
getInputStatus model =
    if isLoading model then
        Disabled
    else
        Enabled


viewSourceTitleInput : UserInput -> RemoteArticle -> InputStatus -> Html Msg
viewSourceTitleInput =
    viewTitleInput SourceArticleTitleChange "From..."


viewDestinationTitleInput : UserInput -> RemoteArticle -> InputStatus -> Html Msg
viewDestinationTitleInput =
    viewTitleInput DestinationArticleTitleChange "To..."


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
            , ButtonOptions.onClick FetchArticlesRequest
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
            , ButtonOptions.onClick FetchRandomTitlesRequest
            ]
            [ text "Randomize" ]
        ]


shouldDisableLoadButton : Model -> Bool
shouldDisableLoadButton model =
    isLoading model
        || isBlank model.sourceTitle
        || isBlank model.destinationTitle


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
            Error.viewArticleError error

        _ ->
            text ""


viewRandomizeTitlesError : Model -> Html msg
viewRandomizeTitlesError { randomTitles } =
    case randomTitles of
        RemoteData.Failure error ->
            Error.viewGeneralError "Error randomizing titles 😵" (toString error)

        _ ->
            text ""


type InputStatus
    = Enabled
    | Disabled
