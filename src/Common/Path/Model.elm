module Common.Path.Model
    exposing
        ( Path
        , startingAt
        , inOrder
        , inReverseOrder
        , priority
        , extend
        , contains
        , nextStop
        , length
        )

import Common.PriorityQueue.Model exposing (Priority)
import Common.Title.Model exposing (Title)


startingAt : Title -> Path
startingAt title =
    Path
        { next = title
        , visited = []
        , priority = 0
        }


inOrder : Path -> List Title
inOrder path =
    inReverseOrder path |> List.reverse


inReverseOrder : Path -> List Title
inReverseOrder (Path path) =
    path.next :: path.visited


priority : Path -> Priority
priority (Path path) =
    path.priority


extend : Path -> Title -> Priority -> Path
extend (Path path) title newPriority =
    Path
        { path
            | next = title
            , visited = path.next :: path.visited
            , priority = newPriority
        }


contains : Title -> Path -> Bool
contains title path =
    inReverseOrder path |> List.member title


nextStop : Path -> Title
nextStop (Path path) =
    path.next


length : Path -> Int
length path =
    inOrder path |> List.length


type Path
    = Path
        { next : Title
        , visited : List Title
        , priority : Priority
        }
