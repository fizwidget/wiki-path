module PathfindingPage.Util exposing (getNextCandidate, hasFinished)

import Common.Model exposing (Title(..), Article)
import PathfindingPage.Model exposing (PathfindingModel)


hasFinished : PathfindingModel -> Bool
hasFinished { stops, end } =
    List.head stops
        |> Maybe.map (\stop -> stop == end.title)
        |> Maybe.withDefault False


getNextCandidate : Article -> PathfindingModel -> Maybe Title
getNextCandidate current model =
    getCandidates current model
        |> calculateBestCandidate model.end


getCandidates : Article -> PathfindingModel -> List Title
getCandidates current model =
    current.links
        |> List.filterMap toArticleTitle


isUnvisited : PathfindingModel -> Title -> Bool
isUnvisited model title =
    (title /= model.start.title)
        && (title /= model.end.title)
        && (not <| List.member title model.stops)


toArticleTitle : Title -> Maybe Title
toArticleTitle (Title link) =
    let
        isNotCategory =
            not <| String.startsWith "Category:" link

        isNotTemplate =
            not <| String.startsWith "Template:" link

        isNotDoc =
            not <| String.startsWith "Wikipedia:" link

        isNotHelp =
            not <| String.startsWith "Help:" link

        isNotIsbn =
            link /= "ISBN"

        isNotDoi =
            link /= "Digital object identifier"

        isNotSpecial =
            not <| String.startsWith "Special:" link

        isNotTemplateTalk =
            not <| String.startsWith "Template talk:" link
    in
        if
            isNotCategory
                && isNotTemplate
                && isNotDoc
                && isNotHelp
                && isNotIsbn
                && isNotDoi
                && isNotSpecial
                && isNotTemplateTalk
        then
            Just <| Title link
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


type alias Link =
    { title : String
    , href : String
    }
