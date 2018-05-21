module Pathfinding.Util exposing (addLinksToQueue)

import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Common.Article.Model exposing (Article)
import Common.Title.Model as Title exposing (Title)
import Common.Path.Model exposing (Path)
import Common.PriorityQueue.Model as PriorityQueue exposing (PriorityQueue, Priority)


addLinksToQueue : PriorityQueue Path -> Article -> Path -> List Title -> PriorityQueue Path
addLinksToQueue priorityQueue destination pathSoFar links =
    links
        |> List.filter isInteresting
        |> List.filter (isUnvisited priorityQueue pathSoFar)
        |> List.map (extendPath pathSoFar destination)
        |> keepHighestPriorityPaths
        |> PriorityQueue.insert priorityQueue .priority


extendPath : Path -> Article -> Title -> Path
extendPath pathSoFar destination nextTitle =
    { priority = calculatePriority destination pathSoFar nextTitle
    , next = nextTitle
    , visited = pathSoFar.next :: pathSoFar.visited
    }


keepHighestPriorityPaths : List Path -> List Path
keepHighestPriorityPaths paths =
    paths
        |> List.sortBy .priority
        |> List.reverse
        |> List.take 2


calculatePriority : Article -> Path -> Title -> Priority
calculatePriority destination pathSoFar title =
    pathSoFar.priority * 0.8 + (heuristic destination title)


heuristic : Article -> Title -> Float
heuristic destination title =
    if title == destination.title then
        1000
    else
        toFloat <| countOccurences destination.content (Title.value title)


countOccurences : String -> String -> Int
countOccurences content target =
    let
        matchTarget =
            ("(^|\\s+|\")" ++ (escape target) ++ "(\\s+|$|\")")
                |> regex
                |> caseInsensitive
    in
        find All matchTarget content
            |> List.length


isUnvisited : PriorityQueue Path -> Path -> Title -> Bool
isUnvisited priorityQueue pathSoFar title =
    priorityQueue
        |> PriorityQueue.toSortedList
        |> (::) pathSoFar
        |> List.concatMap (\pathSoFar -> pathSoFar.next :: pathSoFar.visited)
        |> List.member title
        |> not


isInteresting : Title -> Bool
isInteresting title =
    -- We're filtering out these commonly-occuring links because it's kinda
    -- boring if the majority of paths go via the same links. They wouldn't
    -- normally be followed when playing the Wikipedia game anyway.
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
            , "JSTOR"
            , "Bibcode"
            , "Wayback Machine"
            , "Virtual International Authority File"
            , "Integrated Authority File"
            ]

        titleValue =
            Title.value title

        hasIgnoredPrefix =
            List.any (\prefix -> String.startsWith prefix titleValue) ignoredPrefixes

        hasMinimumLength =
            String.length titleValue > 1
    in
        hasMinimumLength && not hasIgnoredPrefix
