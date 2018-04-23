module Pathfinding.SearchAlgorithm exposing (addNodes)

import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Common.Model.Article exposing (Article)
import Common.Model.Title exposing (Title, value)
import Pathfinding.Model exposing (PathfindingModel, PathPriorityQueue, Path, Cost)
import Pathfinding.Model.PriorityQueue as PriorityQueue


addNodes : PathPriorityQueue -> Article -> Path -> Article -> PathPriorityQueue
addNodes priorityQueue destination pathTaken currentArticle =
    currentArticle.links
        |> List.filter isRegularArticle
        |> List.filter (isUnvisited pathTaken)
        |> List.map (withEstimatedTotalCost destination pathTaken.cost)
        |> List.map (toPath pathTaken)
        |> List.sortBy .cost
        |> List.take 2
        |> PriorityQueue.insert priorityQueue .cost


toPath : Path -> ( Cost, Title ) -> Path
toPath previousPath ( estimatedTotalCost, title ) =
    { cost = estimatedTotalCost
    , next = title
    , visited = previousPath.next :: previousPath.visited
    }


withEstimatedTotalCost : Article -> Cost -> Title -> ( Cost, Title )
withEstimatedTotalCost destination costSoFar title =
    heuristic destination title
        |> (\cost -> cost + costSoFar * 0.8)
        |> (\cost -> ( cost, title ))


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
        -1000
    else
        find All (destinationTitle |> value |> matchWord |> caseInsensitive) content
            |> List.length
            |> (\value -> -value)
            |> toFloat


matchWord : String -> Regex
matchWord target =
    "(^|\\s+|\")" ++ (escape target) ++ "(\\s+|$|\")" |> regex
