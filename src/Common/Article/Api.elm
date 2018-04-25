module Common.Article.Api exposing (requestArticle)

import Http
import Common.Article.Model exposing (ArticleResult)
import Common.Article.Decoder exposing (decodeArticle)
import Common.Url.Model exposing (QueryParam(WithValue, WithNoValue), buildUrl)


requestArticle : String -> Http.Request ArticleResult
requestArticle title =
    Http.get (buildArticleUrl title) decodeArticle


buildArticleUrl : String -> String
buildArticleUrl title =
    let
        baseUrl =
            "https://en.wikipedia.org/w/api.php"

        queryParams =
            [ WithValue ( "action", "parse" )
            , WithNoValue "redirects"
            , WithValue ( "format", "json" )
            , WithValue ( "formatversion", "2" )
            , WithValue ( "origin", "*" )
            , WithValue ( "page", title )
            ]
    in
        buildUrl baseUrl queryParams
