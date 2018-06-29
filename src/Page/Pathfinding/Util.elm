module Page.Pathfinding.Util
    exposing
        ( isCandidate
        , markVisited
        , extendPath
        , discardLowPriorityPaths
        )

import Set exposing (Set)
import Regex exposing (Regex, regex, find, escape, caseInsensitive, HowMany(All))
import Common.Article.Model exposing (Article, Link, Namespace(ArticleNamespace, NonArticleNamespace))
import Common.Title.Model as Title exposing (Title)
import Common.Path.Model as Path exposing (Path)
import Common.PriorityQueue.Model as PriorityQueue exposing (PriorityQueue, Priority)


isCandidate : Set String -> Link -> Bool
isCandidate visitedTitles link =
    let
        title =
            Title.value link.title

        hasMinimumLength =
            String.length title > 1

        isVisited =
            Set.member title visitedTitles

        isRegularArticle =
            link.namespace == ArticleNamespace

        isBlacklisted =
            List.member title
                [ "ISBN"
                , "International Standard Book Number"
                , "International Standard Serial Number"
                , "Digital object identifier"
                , "PubMed"
                , "JSTOR"
                , "Bibcode"
                , "Wayback Machine"
                , "Virtual International Authority File"
                , "Integrated Authority File"
                , "Geographic coordinate system"
                ]
    in
        link.doesExist
            && hasMinimumLength
            && isRegularArticle
            && not isVisited
            && not isBlacklisted


markVisited : Set String -> List Path -> Set String
markVisited visitedTitles newPaths =
    newPaths
        |> List.map (Path.nextStop >> Title.value)
        |> List.foldl Set.insert visitedTitles


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
        10000
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


discardLowPriorityPaths : List Path -> List Path
discardLowPriorityPaths paths =
    paths
        |> List.sortBy (Path.priority >> negate)
        |> List.take 2
