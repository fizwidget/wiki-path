module Pathfinding.Util exposing (addArticleLinks)

import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Common.Model.Article exposing (Article)
import Common.Model.Title as Title exposing (Title)
import Pathfinding.Model exposing (PathfindingModel, Path)
import Pathfinding.Model.PriorityQueue as PriorityQueue exposing (PriorityQueue, Priority)


addArticleLinks : PriorityQueue Path -> Article -> Path -> (Title -> Bool) -> Article -> PriorityQueue Path
addArticleLinks priorityQueue destination pathSoFar isUnvisited currentArticle =
    currentArticle.links
        |> List.filter isRegularArticle
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
            , "Bibcode"
            ]
    in
        List.any (\prefix -> String.startsWith prefix (Title.value title)) ignoredPrefixes
            |> not


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
