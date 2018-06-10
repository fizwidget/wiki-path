module Common.Path.Model
    exposing
        ( Path
        , beginningWith
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


beginningWith : Title -> Path
beginningWith title =
    Path
        { nextStop = title
        , previousStops = []
        , priority = 0
        }


inOrder : Path -> List Title
inOrder =
    inReverseOrder >> List.reverse


inReverseOrder : Path -> List Title
inReverseOrder (Path path) =
    path.nextStop :: path.previousStops


priority : Path -> Priority
priority (Path path) =
    path.priority


extend : Path -> Title -> Priority -> Path
extend (Path path) title newPriority =
    Path
        { path
            | nextStop = title
            , previousStops = path.nextStop :: path.previousStops
            , priority = newPriority
        }


contains : Title -> Path -> Bool
contains title path =
    inReverseOrder path |> List.member title


nextStop : Path -> Title
nextStop (Path path) =
    path.nextStop


length : Path -> Int
length =
    inOrder >> List.length


type Path
    = Path
        { nextStop : Title
        , previousStops : List Title
        , priority : Priority
        }
