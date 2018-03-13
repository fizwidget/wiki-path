module WelcomePage.View.LinkExtractor exposing (Link, getLinks)

import HtmlParser exposing (Node, Attributes)
import HtmlParser.Util exposing (getElementsByTagName, filterElements, mapElements, getValue, textContent)


type alias Link =
    { name : String
    , destination : String
    }


getLinks : List Node -> List Link
getLinks nodes =
    nodes
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
