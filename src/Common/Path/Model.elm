module Common.Path.Model exposing (Path)

import Common.PriorityQueue.Model exposing (Priority)
import Common.Title.Model exposing (Title)


type alias Path =
    { priority : Priority
    , next : Title
    , visited : List Title
    }
