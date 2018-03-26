module PathfindingPage.Util exposing (getNextCandidate)

import Common.Model exposing (Title(..), Article)
import PathfindingPage.Model exposing (Model)


getNextCandidate : Article -> Model -> Maybe Title
getNextCandidate current model =
    getCandidates current model
        |> calculateBestCandidate model.end


getCandidates : Article -> Model -> List Title
getCandidates current model =
    current.links
        |> List.filterMap toArticleTitle


isUnvisited : Model -> Title -> Bool
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
