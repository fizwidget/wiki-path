module LinkExtractor exposing (Link, getLinks)

import HtmlParser exposing (Node, Attributes, parse)
import HtmlParser.Util exposing (getElementsByTagName, filterElements, mapElements, getValue, textContent)
import Model.Content exposing (Content)


type alias Link =
    { name : String
    , destination : String
    }


getLinks : Content -> List Link
getLinks content =
    content
        |> getElementsByTagName "a"
        |> filterElements isArticleLink
        |> mapElements buildLink
        |> List.filterMap identity


buildLink : String -> Attributes -> List Node -> Maybe Link
buildLink tagName attributes children =
    let
        getAttribute name =
            getValue name attributes

        title =
            getAttribute "title"

        href =
            getAttribute "href"
    in
        Maybe.map2 Link title href


isArticleLink : String -> Attributes -> List Node -> Bool
isArticleLink tagName attributes children =
    case getValue "href" attributes of
        Just href ->
            String.startsWith "/wiki" href

        Nothing ->
            False
