module PathfindingPage.View.Content exposing (articlesContent)

import Html exposing (Html, div, text, h2, a, ul, li)
import Html.Attributes exposing (style, href)
import Html.Lazy exposing (lazy)
import Common.Model exposing (Article, RemoteArticle, ArticleError(..))
import PathfindingPage.View.LinkExtractor exposing (Link, getLinks)


articlesContent : Article -> Article -> Html msg
articlesContent source destination =
    div [ style [ ( "display", "flex" ), ( "align-items", "top" ) ] ]
        [ displayArticle source
        , displayArticle destination
        ]


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
    ul []
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
