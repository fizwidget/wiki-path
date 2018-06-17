module Common.Path.Model
    exposing
        ( Path
        , beginningWith
        , beginning
        , end
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
beginningWith articleTitle =
    Path
        { nextStop = articleTitle
        , previousStops = []
        , priority = 0
        }


beginning : Path -> Title
beginning (Path path) =
    path.previousStops
        |> List.reverse
        |> List.head
        |> Maybe.withDefault path.nextStop


end : Path -> Title
end (Path path) =
    path.nextStop


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
extend (Path path) nextArticleTitle newPriority =
    Path
        { path
            | nextStop = nextArticleTitle
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
    inReverseOrder >> List.length


type Path
    = Path
        { nextStop : Title
        , previousStops : List Title
        , priority : Priority
        }
