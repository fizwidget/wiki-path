module Pathfinding.Util exposing (addLinks)

import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Common.Article.Model exposing (Article)
import Common.Title.Model as Title exposing (Title)
import Common.PriorityQueue.Model as PriorityQueue exposing (PriorityQueue, Priority)
import Pathfinding.Model exposing (PathfindingModel, Path)


addLinks : PriorityQueue Path -> Article -> Path -> List Title -> PriorityQueue Path
addLinks priorityQueue destination pathSoFar links =
    links
        |> List.filter isNotIgnored
        |> List.filter (isUnvisited priorityQueue pathSoFar)
        |> List.map (extendPath pathSoFar destination)
        |> List.sortBy .priority
        |> List.reverse
        |> List.take 2
        |> PriorityQueue.insert priorityQueue .priority


extendPath : Path -> Article -> Title -> Path
extendPath pathSoFar destination nextTitle =
    { priority = calculatePriority destination pathSoFar nextTitle
    , next = nextTitle
    , visited = pathSoFar.next :: pathSoFar.visited
    }


calculatePriority : Article -> Path -> Title -> Priority
calculatePriority destination pathSoFar title =
    pathSoFar.priority * 0.8 + (heuristic destination title)


heuristic : Article -> Title -> Float
heuristic { title, content } destinationTitle =
    if title == destinationTitle then
        1000
    else
        find All (destinationTitle |> Title.value |> matchWord |> caseInsensitive) content
            |> List.length
            |> toFloat


matchWord : String -> Regex
matchWord target =
    "(^|\\s+|\")" ++ (escape target) ++ "(\\s+|$|\")" |> regex


isUnvisited : PriorityQueue Path -> Path -> Title -> Bool
isUnvisited priorityQueue pathSoFar title =
    priorityQueue
        |> PriorityQueue.toSortedList
        |> (::) pathSoFar
        |> List.concatMap (\pathSoFar -> pathSoFar.next :: pathSoFar.visited)
        |> List.member title
        |> not


isNotIgnored : Title -> Bool
isNotIgnored title =
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
            ]

        titleValue =
            Title.value title

        hasIgnoredPrefix =
            List.any (\prefix -> String.startsWith prefix titleValue) ignoredPrefixes

        hasMinimumLength =
            String.length titleValue > 1
    in
        hasMinimumLength && not hasIgnoredPrefix
