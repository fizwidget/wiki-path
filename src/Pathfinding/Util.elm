module Pathfinding.Util
    exposing
        ( extendPath
        , isInteresting
        , isUnvisited
        , markVisited
        , discardLowPriorityPaths
        )

import Set exposing (Set)
import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Common.Article.Model exposing (Article, Link, Namespace(ArticleNamespace, NonArticleNamespace))
import Common.Title.Model as Title exposing (Title)
import Common.Path.Model as Path exposing (Path)
import Common.PriorityQueue.Model as PriorityQueue exposing (PriorityQueue, Priority)


extendPath : Path -> Article -> Link -> Path
extendPath currentPath destination link =
    Path.extend
        currentPath
        link.title
        (calculatePriority destination currentPath link.title)


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


isUnvisited : Set String -> Link -> Bool
isUnvisited visitedTitles link =
    Set.member (Title.value link.title) visitedTitles
        |> not


markVisited : Set String -> List Path -> Set String
markVisited visitedTitles newPaths =
    newPaths
        |> List.map (Path.nextStop >> Title.value)
        |> List.foldl Set.insert visitedTitles


isInteresting : Link -> Bool
isInteresting link =
    -- We're filtering out these commonly-occuring links because it's kinda
    -- boring if the majority of paths go via the same links. They wouldn't
    -- normally be followed when playing the Wikipedia game anyway.
    let
        ignoredPrefixes =
            [ "ISBN"
            , "International Standard Book Number"
            , "Digital object identifier"
            , "International Standard Serial Number"
            , "PubMed"
            , "JSTOR"
            , "Bibcode"
            , "Wayback Machine"
            , "Virtual International Authority File"
            , "Integrated Authority File"
            , "Geographic coordinate system"
            ]

        titleValue =
            Title.value link.title

        hasIgnoredPrefix =
            List.any (\prefix -> String.startsWith prefix titleValue) ignoredPrefixes

        hasMinimumLength =
            String.length titleValue > 1

        isInArticleNamespace =
            case link.namespace of
                ArticleNamespace ->
                    True

                NonArticleNamespace ->
                    False
    in
        link.doesExist && isInArticleNamespace && hasMinimumLength && not hasIgnoredPrefix


discardLowPriorityPaths : List Path -> List Path
discardLowPriorityPaths paths =
    -- This is really just a performance improvement to prevent the
    -- number of paths we're considering at any one time from increasing
    -- too rapidly. Articles can have *lots* of links.
    paths
        |> List.sortBy Path.priority
        |> List.reverse
        |> List.take 2
