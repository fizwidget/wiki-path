module Pathfinding.Util exposing (getNextStop)

import Regex exposing (regex, find, escape, caseInsensitive, HowMany(All))
import Common.Model exposing (Title(..), Article, value)
import Pathfinding.Model exposing (PathfindingModel)


getNextStop : Article -> PathfindingModel -> Maybe Title
getNextStop current model =
    getCandidates current model
        |> calculateBestCandidate model.end


getCandidates : Article -> PathfindingModel -> List Title
getCandidates current model =
    current.links
        |> List.filter isValidTitle
        |> List.filter (isUnvisited model)


isUnvisited : PathfindingModel -> Title -> Bool
isUnvisited model title =
    (title /= model.start.title)
        && (not <| List.member title model.stops)


isValidTitle : Title -> Bool
isValidTitle (Title value) =
    let
        ignorePrefixes =
            [ "Category:"
            , "Template:"
            , "Wikipedia:"
            , "Help:"
            , "Special:"
            , "Template talk:"
            , "ISBN"
            , "Digital object identifier"
            , "Portal:"
            , "Book:"
            , "User:"
            , "Commons"
            , "Talk:"
            , "Wikipedia talk:"
            , "User talk:"
            ]
    in
        not <| List.any (\prefix -> String.startsWith prefix value) ignorePrefixes


calculateBestCandidate : Article -> List Title -> Maybe Title
calculateBestCandidate end candidateTitles =
    candidateTitles
        |> List.map (\title -> ( title, occuranceCount end title ))
        |> List.sortBy (\( title, count ) -> count)
        |> List.reverse
        |> List.take 3
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
