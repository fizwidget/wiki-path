module Pathfinding.Util exposing (addNodes)

import PairingHeap exposing (PairingHeap)
import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Common.Model.Article exposing (Article)
import Common.Model.Title exposing (Title, value)
import Pathfinding.Model exposing (PathfindingModel, Path)


addNodes : PathfindingModel -> Path -> Article -> PathfindingModel
addNodes model pathTaken currentArticle =
    let
        possibleDestinations =
            currentArticle.links
                |> List.filter isRegularArticle
                |> List.filter (\title -> title /= currentArticle.title)
                |> List.filter (\title -> not <| List.member title pathTaken.visited)
                |> List.map (\title -> ( heuristic model.destination title, title ))
                |> List.map (\( cost, title ) -> ( cost + pathTaken.cost * 0.8, title ))
                |> List.sortBy Tuple.first
                |> List.take 2

        insert ( cost, title ) queue =
            PairingHeap.insert
                ( cost
                , { cost = cost
                  , next = title
                  , visited = pathTaken.next :: pathTaken.visited
                  }
                )
                queue

        updatedPriorityQueue =
            List.foldl insert model.priorityQueue possibleDestinations
    in
        { model | priorityQueue = updatedPriorityQueue }


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


heuristic : Article -> Title -> Float
heuristic { content } title =
    find All (title |> value |> matchWord |> caseInsensitive) content
        |> List.length
        |> (\value -> -value)
        |> toFloat


matchWord : String -> Regex
matchWord target =
    "(^|\\s+|\")" ++ (escape target) ++ "(\\s+|$|\")" |> regex
