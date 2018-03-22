module PathfindingPage.Util exposing (getNextCandidate)

import HtmlParser exposing (Node, Attributes)
import HtmlParser.Util exposing (getElementsByTagName, mapElements, getValue)
import Common.Model exposing (Title(..), Article)
import PathfindingPage.Model exposing (Model)


getNextCandidate : Article -> Model -> Maybe Title
getNextCandidate current model =
    getCandidates current model
        |> calculateBestCandidate model.end


getCandidates : Article -> Model -> List Title
getCandidates current model =
    current.content
        |> extractLinks
        |> List.filterMap toArticleTitle
        |> List.filter (isUnvisited model)


isUnvisited : Model -> Title -> Bool
isUnvisited model title =
    (title /= model.start.title)
        && (title /= model.end.title)
        && (not <| List.member title model.stops)


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

        isNotTemplateTalk =
            not <| String.startsWith "Template talk:" link.title
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
                && isNotTemplateTalk
        then
            Just <| Title link.title
        else
            Nothing


calculateBestCandidate : Article -> List Title -> Maybe Title
calculateBestCandidate end candidateTitles =
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
