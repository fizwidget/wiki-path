module Page.Setup exposing
    ( Model
    , Msg
    , UpdateResult(..)
    , init
    , initWithArticles
    , update
    , view
    )

import Article exposing (Article, ArticleError(..), ArticleResult, Full, Preview)
import Cmd.Extra exposing (withCmd, withNoCmd)
import Css exposing (..)
import Html.Styled exposing (Html, button, div, form, text)
import Html.Styled.Attributes exposing (css, placeholder, type_, value)
import Html.Styled.Events exposing (onSubmit)
import Http
import RemoteData exposing (RemoteData(..), WebData)
import View.Button as Button
import View.Empty as Empty
import View.Input as Input
import View.Spinner as Spinner



-- MODEL


type alias Model =
    { sourceInput : UserInput
    , destinationInput : UserInput
    , source : RemoteArticle
    , destination : RemoteArticle
    , randomArticles : RemoteArticlePair
    }


type alias UserInput =
    String


type alias RemoteArticlePair =
    RemoteData RemoteArticlePairError ( Article Preview, Article Preview )


type RemoteArticlePairError
    = UnexpectedArticleCount
    | HttpError Http.Error


type alias RemoteArticle =
    RemoteData ArticleError (Article Full)



-- INIT


init : ( Model, Cmd Msg )
init =
    ( initialModel "" "", Cmd.none )


initWithArticles : Article a -> Article a -> ( Model, Cmd Msg )
initWithArticles source destination =
    ( initialModel (Article.getTitle source) (Article.getTitle destination)
    , Cmd.none
    )


initialModel : String -> String -> Model
initialModel sourceInput destinationInput =
    { sourceInput = sourceInput
    , destinationInput = destinationInput
    , source = NotAsked
    , destination = NotAsked
    , randomArticles = NotAsked
    }



-- UPDATE


type Msg
    = SourceInputChange UserInput
    | DestinationInputChange UserInput
    | FetchArticlesRequest
    | FetchSourceArticleResponse RemoteArticle
    | FetchDestinationArticleResponse RemoteArticle
    | FetchRandomArticlesRequest
    | FetchRandomArticlesResponse RemoteArticlePair


type UpdateResult
    = InProgress ( Model, Cmd Msg )
    | Complete (Article Full) (Article Full)


update : Msg -> Model -> UpdateResult
update msg model =
    case msg of
        SourceInputChange input ->
            { model | sourceInput = input, source = NotAsked, randomArticles = NotAsked }
                |> withNoCmd
                |> InProgress

        DestinationInputChange input ->
            { model | destinationInput = input, destination = NotAsked, randomArticles = NotAsked }
                |> withNoCmd
                |> InProgress

        FetchRandomArticlesRequest ->
            { model | randomArticles = Loading }
                |> withCmd fetchRandomPair
                |> InProgress

        FetchRandomArticlesResponse response ->
            { model | randomArticles = response }
                |> randomizeArticleInputs
                |> withNoCmd
                |> InProgress

        FetchArticlesRequest ->
            { model | source = Loading, destination = Loading }
                |> withCmd (fetchFullArticles model)
                |> InProgress

        FetchSourceArticleResponse article ->
            { model | source = article }
                |> maybeComplete

        FetchDestinationArticleResponse article ->
            { model | destination = article }
                |> maybeComplete


maybeComplete : Model -> UpdateResult
maybeComplete ({ source, destination } as model) =
    RemoteData.map2 Complete source destination
        |> RemoteData.withDefault (model |> withNoCmd |> InProgress)



-- FETCH RANDOM PAIR


fetchRandomPair : Cmd Msg
fetchRandomPair =
    Article.fetchRandom 2
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteArticlePair >> FetchRandomArticlesResponse)


toRemoteArticlePair : WebData (List (Article Preview)) -> RemoteArticlePair
toRemoteArticlePair remoteArticles =
    remoteArticles
        |> RemoteData.mapError HttpError
        |> RemoteData.andThen toPair


toPair : List (Article Preview) -> RemoteArticlePair
toPair articles =
    case articles of
        first :: second :: _ ->
            RemoteData.succeed ( first, second )

        _ ->
            RemoteData.Failure UnexpectedArticleCount


randomizeArticleInputs : Model -> Model
randomizeArticleInputs model =
    let
        setArticleInputs ( source, destination ) =
            { model
                | source = NotAsked
                , destination = NotAsked
                , sourceInput = Article.getTitle source
                , destinationInput = Article.getTitle destination
            }
    in
    model.randomArticles
        |> RemoteData.map setArticleInputs
        |> RemoteData.withDefault model



-- FETCH FULL ARTICLE


fetchFullArticles : Model -> Cmd Msg
fetchFullArticles { sourceInput, destinationInput } =
    Cmd.batch
        [ fetchFullArticle FetchSourceArticleResponse sourceInput
        , fetchFullArticle FetchDestinationArticleResponse destinationInput
        ]


fetchFullArticle : (RemoteArticle -> msg) -> String -> Cmd msg
fetchFullArticle toMsg title =
    title
        |> Article.fetchNamed
        |> RemoteData.sendRequest
        |> Cmd.map (toRemoteArticle >> toMsg)


toRemoteArticle : WebData ArticleResult -> RemoteArticle
toRemoteArticle webData =
    webData
        |> RemoteData.mapError Article.HttpError
        |> RemoteData.andThen RemoteData.fromResult



-- VIEW


view : Model -> Html Msg
view model =
    form
        [ css
            [ displayFlex
            , alignItems center
            , flexDirection column
            ]
        , onSubmit FetchArticlesRequest
        ]
        [ viewArticleInputs model
        , viewFindPathButton model
        , viewRandomizeButton (isLoading model)
        , viewRandomizationError model.randomArticles
        , viewLoadingSpinner (isLoading model)
        ]


viewArticleInputs : Model -> Html Msg
viewArticleInputs ({ sourceInput, destinationInput, source, destination } as model) =
    div [ css [ displayFlex, justifyContent center, flexWrap wrap ] ]
        [ viewSourceArticleInput sourceInput source (isLoading model)
        , viewDestinationArticleInput destinationInput destination (isLoading model)
        ]


viewSourceArticleInput : UserInput -> RemoteArticle -> Bool -> Html Msg
viewSourceArticleInput =
    viewArticleInput SourceInputChange "From..."


viewDestinationArticleInput : UserInput -> RemoteArticle -> Bool -> Html Msg
viewDestinationArticleInput =
    viewArticleInput DestinationInputChange "To..."


viewArticleInput : (UserInput -> Msg) -> String -> String -> RemoteArticle -> Bool -> Html Msg
viewArticleInput toMsg placeholder title article isDisabled =
    div
        [ css
            [ padding2 (px 0) (px 8)
            , height (px 76)
            , textAlign center
            ]
        ]
        [ Input.text
            [ Input.Large
            , Input.OnInput toMsg
            , Input.Value title
            , Input.Placeholder placeholder
            , Input.Disabled isDisabled
            , Input.Error (RemoteData.isFailure article)
            ]
        , viewArticleError article
        ]


viewFindPathButton : Model -> Html Msg
viewFindPathButton model =
    div [ css [ padding (px 4) ] ]
        [ Button.view "Find path"
            [ Button.Primary
            , Button.Large
            , Button.Disabled (shouldDisableLoadButton model)
            ]
        ]


viewRandomizeButton : Bool -> Html Msg
viewRandomizeButton isDisabled =
    div [ css [ paddingTop (px 8) ] ]
        [ Button.view "Randomize"
            [ Button.Secondary
            , Button.Large
            , Button.Disabled isDisabled
            , Button.OnClick FetchRandomArticlesRequest
            ]
        ]


viewArticleError : RemoteArticle -> Html msg
viewArticleError remoteArticle =
    case remoteArticle of
        RemoteData.Failure error ->
            Article.viewError error

        _ ->
            Empty.view


viewRandomizationError : RemoteArticlePair -> Html msg
viewRandomizationError randomArticles =
    if RemoteData.isFailure randomArticles then
        text "Sorry, an error occured 😵"

    else
        Empty.view


viewLoadingSpinner : Bool -> Html msg
viewLoadingSpinner isVisible =
    if isVisible then
        Spinner.view

    else
        Empty.view


shouldDisableLoadButton : Model -> Bool
shouldDisableLoadButton model =
    isLoading model
        || isBlank model.sourceInput
        || isBlank model.destinationInput


isBlank : String -> Bool
isBlank =
    String.trim >> String.isEmpty


isLoading : Model -> Bool
isLoading { source, destination, randomArticles } =
    RemoteData.isLoading randomArticles
        || List.any RemoteData.isLoading [ source, destination ]
