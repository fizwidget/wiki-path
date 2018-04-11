module Pathfinding.Util exposing (suggestNextArticle)

import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Common.Model.Article exposing (Article)
import Common.Model.Title exposing (Title, value)
import Pathfinding.Model exposing (PathfindingModel)


suggestNextArticle : PathfindingModel -> Article -> Maybe Title
suggestNextArticle model current =
    getCandidates current model
        |> calculateBestCandidate model.destination


getCandidates : Article -> PathfindingModel -> List Title
getCandidates current model =
    current.links
        |> List.filter isRegularArticle
        |> List.filter (\title -> title /= current.title)
        |> List.filter (isUnvisited model)


isUnvisited : PathfindingModel -> Title -> Bool
isUnvisited model title =
    (title /= model.source.title)
        && (not <| List.member title model.stops)


isRegularArticle : Title -> Bool
isRegularArticle title =
    let
        ignoredPrefixes =
            [ "Category:"
            , "Template:"
            , "Wikipedia:"
            , "Help:"
            , "Special:"
            , "Template talk:"
            , "ISBN"
            , "International Standard Book Number"
            , "Digital object identifier"
            , "Portal:"
            , "Book:"
            , "User:"
            , "Commons"
            , "Talk:"
            , "Wikipedia talk:"
            , "User talk:"
            , "Module:"
            , "File:"
            , "International Standard Serial Number"
            , "PubMed"
            ]
    in
        List.any (\prefix -> String.startsWith prefix (value title)) ignoredPrefixes
            |> not


calculateBestCandidate : Article -> List Title -> Maybe Title
calculateBestCandidate destination candidateTitles =
    candidateTitles
        |> List.map (\title -> ( title, heuristic destination title ))
        |> List.sortBy (\( title, count ) -> -count)
        |> List.take 3
        |> Debug.log "Occurence counts"
        |> List.map Tuple.first
        |> List.head


heuristic : Article -> Title -> Int
heuristic { content } title =
    find All (title |> value |> matchWord |> caseInsensitive) content
        |> List.length


matchWord : String -> Regex
matchWord target =
    "(^|\\s+|\")" ++ (escape target) ++ "(\\s+|$|\")" |> regex


type alias Link =
    { title : String
    , href : String
    }
