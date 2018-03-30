module Pathfinding.Util exposing (getNextCandidate)

import Regex exposing (regex, find, escape, caseInsensitive, HowMany(All))
import Common.Model exposing (Title(..), Article, value)
import Pathfinding.Model exposing (PathfindingModel)


getNextCandidate : Article -> PathfindingModel -> Maybe Title
getNextCandidate current model =
    getCandidates current model
        |> calculateBestCandidate model.end


getCandidates : Article -> PathfindingModel -> List Title
getCandidates current model =
    current.links
        |> List.filterMap toArticleTitle
        |> List.filter (isUnvisited model)


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
    candidateTitles
        |> List.map (\title -> ( title, occuranceCount end title ))
        |> List.sortBy (\( title, count ) -> count)
        |> List.take 5
        |> Debug.log "Occurence counts"
        |> List.head
        |> Maybe.map Tuple.first


occuranceCount : Article -> Title -> Int
occuranceCount article title =
    find All (title |> value |> escape |> regex |> caseInsensitive) article.content
        |> List.length


type alias Link =
    { title : String
    , href : String
    }
