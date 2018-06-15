module Pathfinding.Util
    exposing
        ( extendPath
        , isInteresting
        , isUnvisited
        , keepHighestPriorities
        )

import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Common.Article.Model exposing (Article)
import Common.Title.Model as Title exposing (Title)
import Common.Path.Model as Path exposing (Path)
import Common.PriorityQueue.Model as PriorityQueue exposing (PriorityQueue, Priority)


extendPath : Path -> Article -> Title -> Path
extendPath currentPath destination nextTitle =
    Path.extend
        currentPath
        nextTitle
        (calculatePriority destination currentPath nextTitle)


calculatePriority : Article -> Path -> Title -> Priority
calculatePriority destination currentPath title =
    (Path.priority currentPath) * 0.8 + (heuristic destination title)


heuristic : Article -> Title -> Float
heuristic destination title =
    if title == destination.title then
        1000
    else
        toFloat <| countOccurences destination.content (Title.value title)


countOccurences : String -> String -> Int
countOccurences content target =
    let
        occurencePattern =
            ("(^|\\s+|\")" ++ (escape target) ++ "(\\s+|$|\")")
                |> regex
                |> caseInsensitive
    in
        find All occurencePattern content
            |> List.length


isUnvisited : PriorityQueue Path -> Path -> Title -> Bool
isUnvisited paths currentPath title =
    paths
        |> PriorityQueue.toSortedList
        |> (::) currentPath
        |> List.any (Path.contains title)
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


keepHighestPriorities : List Path -> List Path
keepHighestPriorities paths =
    -- This is really just a performance improvement to prevent the
    -- number of paths we're considering at any one time from increasing
    -- too rapidly. Articles can have *lots* of links.
    paths
        |> List.sortBy Path.priority
        |> List.reverse
        |> List.take 2
