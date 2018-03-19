module PathfindingPage.Util exposing (getNextCandidate)

import HtmlParser exposing (Node, Attributes)
import HtmlParser.Util exposing (getElementsByTagName, mapElements, getValue)
import Common.Model exposing (Title(..), Article)


getNextCandidate : Article -> Article -> List Title -> Maybe Title
getNextCandidate current destination visited =
    getCandidates current destination visited
        |> calculateBestCandidate destination


getCandidates : Article -> Article -> List Title -> List Title
getCandidates current destination visited =
    current.content
        |> extractLinks
        |> List.filterMap toArticleTitle
        |> List.filter (isUnvisited visited)


isUnvisited : List Title -> Title -> Bool
isUnvisited visited title =
    not <| List.member title visited


toArticleTitle : Link -> Maybe Title
toArticleTitle link =
    let
        isInternalLink =
            String.startsWith "/wiki" link.href

        isNotCategory =
            not <| String.startsWith "Category:" link.title

        isNotTemplate =
            not <| String.startsWith "Template:" link.title

        isNotDoc =
            not <| String.startsWith "Wikipedia:" link.title

        isNotHelp =
            not <| String.startsWith "Help:" link.title

        isNotIsbn =
            link.title /= "ISBN"

        isNotDoi =
            link.title /= "Digital object identifier"

        isNotSpecial =
            not <| String.startsWith "Special:" link.title
    in
        if
            isInternalLink
                && isNotCategory
                && isNotTemplate
                && isNotDoc
                && isNotHelp
                && isNotIsbn
                && isNotDoi
                && isNotSpecial
        then
            Just <| Title link.title
        else
            Nothing


calculateBestCandidate : Article -> List Title -> Maybe Title
calculateBestCandidate destination candidateTitles =
    let
        quarterIndex =
            List.length candidateTitles // 4
    in
        List.drop quarterIndex candidateTitles
            |> List.head


extractLinks : List Node -> List Link
extractLinks nodes =
    nodes
        |> getElementsByTagName "a"
        |> mapElements toLink
        |> List.filterMap identity


toLink : String -> Attributes -> List Node -> Maybe Link
toLink tagName attributes children =
    let
        getAttribute name =
            getValue name attributes

        title =
            getAttribute "title"

        href =
            getAttribute "href"
    in
        Maybe.map2 Link title href


type alias Link =
    { title : String
    , href : String
    }
