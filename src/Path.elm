module Path exposing
    ( Path
    , beginning
    , beginningAt
    , contains
    , end
    , extend
    , inOrder
    , inReverseOrder
    , length
    , priority
    )

import Article exposing (Article, Preview)
import PriorityQueue exposing (Priority)


type Path
    = Path
        { previousStops : List (Article Preview)
        , lastStop : Article Preview
        , priority : Priority
        }


beginningAt : Article a -> Path
beginningAt article =
    Path
        { previousStops = []
        , lastStop = Article.preview article
        , priority = 0
        }


beginning : Path -> Article Preview
beginning (Path path) =
    path.previousStops
        |> List.reverse
        |> List.head
        |> Maybe.withDefault path.lastStop


end : Path -> Article Preview
end (Path path) =
    path.lastStop


inOrder : Path -> List (Article Preview)
inOrder =
    inReverseOrder >> List.reverse


inReverseOrder : Path -> List (Article Preview)
inReverseOrder (Path path) =
    path.lastStop :: path.previousStops


priority : Path -> Priority
priority (Path path) =
    path.priority


extend : Path -> Article Preview -> Priority -> Path
extend (Path path) nextLink nextPriority =
    Path
        { path
            | lastStop = nextLink
            , previousStops = path.lastStop :: path.previousStops
            , priority = nextPriority
        }


contains : Article Preview -> Path -> Bool
contains article path =
    path
        |> inReverseOrder
        |> List.member article


length : Path -> Int
length =
    inReverseOrder >> List.length
