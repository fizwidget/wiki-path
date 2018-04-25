module Pathfinding.Util exposing (addLinks)

import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Common.Model.Article exposing (Article)
import Common.Model.Title as Title exposing (Title)
import Pathfinding.Model exposing (PathfindingModel, Path)
import Pathfinding.Model.PriorityQueue as PriorityQueue exposing (PriorityQueue, Priority)


addLinks : PriorityQueue Path -> Article -> Path -> (Title -> Bool) -> Article -> PriorityQueue Path
addLinks priorityQueue destination pathSoFar isUnvisited currentArticle =
    currentArticle.links
        |> List.filter isNotIgnored
        |> List.filter isUnvisited
        |> List.map (extendPath pathSoFar destination)
        |> List.sortBy .priority
        |> List.reverse
        |> List.take 2
        |> PriorityQueue.insert priorityQueue .priority


extendPath : Path -> Article -> Title -> Path
extendPath pathSoFar destination nextTitle =
    { priority = getPriority destination pathSoFar nextTitle
    , next = nextTitle
    , visited = pathSoFar.next :: pathSoFar.visited
    }


getPriority : Article -> Path -> Title -> Priority
getPriority destination pathSoFar title =
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
