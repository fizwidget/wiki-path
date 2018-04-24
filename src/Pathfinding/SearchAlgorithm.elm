module Pathfinding.SearchAlgorithm exposing (addNodes)

import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Common.Model.Article exposing (Article)
import Common.Model.Title exposing (Title, value)
import Pathfinding.Model exposing (PathfindingModel, Path)
import Pathfinding.Model.PriorityQueue as PriorityQueue exposing (PriorityQueue, Priority)


addNodes : PriorityQueue Path -> Article -> Path -> Article -> PriorityQueue Path
addNodes priorityQueue destination pathTaken currentArticle =
    currentArticle.links
        |> List.filter isRegularArticle
        |> List.filter (isUnvisited pathTaken)
        |> List.map (withPriority destination pathTaken.priority)
        |> List.map (toPath pathTaken)
        |> List.sortBy .priority
        |> List.reverse
        |> List.take 2
        |> PriorityQueue.insert priorityQueue .priority


toPath : Path -> ( Priority, Title ) -> Path
toPath previousPath ( estimatedTotalPriority, title ) =
    { priority = estimatedTotalPriority
    , next = title
    , visited = previousPath.next :: previousPath.visited
    }


withPriority : Article -> Priority -> Title -> ( Priority, Title )
withPriority destination previousPriority title =
    heuristic destination title
        |> (\priority -> priority + previousPriority * 0.8)
        |> (\priority -> ( priority, title ))


isUnvisited : Path -> Title -> Bool
isUnvisited { next, visited } title =
    (title /= next) && (not <| List.member title visited)


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
            , "JSTOR"
            ]
    in
        List.any (\prefix -> String.startsWith prefix (value title)) ignoredPrefixes
            |> not


heuristic : Article -> Title -> Float
heuristic { title, content } destinationTitle =
    if title == destinationTitle then
        1000
    else
        find All (destinationTitle |> value |> matchWord |> caseInsensitive) content
            |> List.length
            |> toFloat


matchWord : String -> Regex
matchWord target =
    "(^|\\s+|\")" ++ (escape target) ++ "(\\s+|$|\")" |> regex
