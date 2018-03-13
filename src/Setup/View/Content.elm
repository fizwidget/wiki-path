module Setup.View.Content exposing (articlesContent)

import RemoteData
import Html exposing (Html, div, text, h2, a, ol, li)
import Html.Attributes exposing (style, href)
import Html.Lazy exposing (lazy)
import Common.Model exposing (Article, RemoteArticle, ArticleError(..))
import Setup.View.LinkExtractor exposing (Link, getLinks)


articlesContent : RemoteArticle -> RemoteArticle -> Html msg
articlesContent sourceArticle destinationArticle =
    div [ style [ ( "display", "flex" ), ( "align-items", "top" ) ] ]
        [ displayRemoteArticle sourceArticle
        , displayRemoteArticle destinationArticle
        ]


displayRemoteArticle : RemoteArticle -> Html msg
displayRemoteArticle article =
    div [ style [ ( "flex", "1" ), ( "max-width", "50%" ) ] ]
        [ case article of
            RemoteData.NotAsked ->
                text ""

            RemoteData.Loading ->
                text "Loading..."

            RemoteData.Success article ->
                displayArticle article

            RemoteData.Failure error ->
                displayError error
        ]


displayError : ArticleError -> Html msg
displayError error =
    case error of
        ArticleNotFound ->
            text "Not found"

        UnknownError errorCode ->
            text ("Unknown error: " ++ errorCode)

        NetworkError error ->
            text ("Network error: " ++ toString error)


displayArticle : Article -> Html msg
displayArticle =
    lazy
        (\{ title, content } ->
            div []
                [ h2 [] [ text title ]
                , displayLinks (getLinks content)
                ]
        )


displayLinks : List Link -> Html msg
displayLinks links =
    ol []
        (List.map displayLink links)


displayLink : Link -> Html msg
displayLink { name, destination } =
    li []
        [ a
            [ href ("https://en.wikipedia.org" ++ destination)
            , (style [ ( "color", "hotpink" ) ])
            ]
            [ text name ]
        ]
