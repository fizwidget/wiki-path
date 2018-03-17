module PathfindingPage.Util exposing (getCandidate)

import HtmlParser exposing (Node, Attributes)
import HtmlParser.Util exposing (getElementsByTagName, filterElements, mapElements, getValue, textContent)
import Common.Model exposing (Article)


type alias Link =
    { name : String
    , destinationTitle : String
    }


getCandidate : Article -> Article -> (String -> Bool) -> Maybe String
getCandidate current destination hasVisited =
    let
        items =
            current.content
                |> getLinks
                |> List.map .name
                |> List.filter (\x -> not (hasVisited x))

        midIndex =
            List.length items // 2
    in
        List.drop midIndex items |> List.head


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
