module Path
    exposing
        ( Path
        , beginningAt
        , beginning
        , end
        , inOrder
        , inReverseOrder
        , priority
        , extend
        , contains
        , length
        )

import PriorityQueue exposing (Priority)
import Title exposing (Title)


type Path
    = Path
        { previousStops : List Title
        , lastStop : Title
        , priority : Priority
        }


beginningAt : Title -> Path
beginningAt title =
    Path
        { previousStops = []
        , lastStop = title
        , priority = 0
        }


beginning : Path -> Title
beginning (Path path) =
    path.previousStops
        |> List.reverse
        |> List.head
        |> Maybe.withDefault path.lastStop


end : Path -> Title
end (Path path) =
    path.lastStop


inOrder : Path -> List Title
inOrder =
    inReverseOrder >> List.reverse


inReverseOrder : Path -> List Title
inReverseOrder (Path path) =
    path.lastStop :: path.previousStops


priority : Path -> Priority
priority (Path path) =
    path.priority


extend : Path -> Title -> Priority -> Path
extend (Path path) nextTitle nextPriority =
    Path
        { path
            | lastStop = nextTitle
            , previousStops = path.lastStop :: path.previousStops
            , priority = nextPriority
        }


contains : Title -> Path -> Bool
contains title path =
    path
        |> inReverseOrder
        |> List.member title


length : Path -> Int
length =
    inReverseOrder >> List.length
