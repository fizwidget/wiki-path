module Pathfinding.Model.PriorityQueue exposing (PriorityQueue, empty, insert, popMin, isEmpty, toSortedList)

import PairingHeap exposing (PairingHeap)


type PriorityQueue comparable a
    = PriorityQueue (PairingHeap comparable a)


empty : PriorityQueue comparable a
empty =
    PriorityQueue PairingHeap.empty


insert : PriorityQueue comparable a -> (a -> comparable) -> List a -> PriorityQueue comparable a
insert (PriorityQueue queue) getPriority values =
    let
        withPriority =
            \value -> ( getPriority value, value )

        valuesWithPriorities =
            List.map withPriority values
    in
        List.foldl PairingHeap.insert queue valuesWithPriorities |> PriorityQueue


popMin : PriorityQueue comparable a -> ( Maybe a, PriorityQueue comparable a )
popMin (PriorityQueue queue) =
    ( PairingHeap.findMin queue |> Maybe.map Tuple.second
    , PairingHeap.deleteMin queue |> PriorityQueue
    )


isEmpty : PriorityQueue comparable a -> Bool
isEmpty (PriorityQueue queue) =
    PairingHeap.findMin queue
        |> Maybe.map (always True)
        |> Maybe.withDefault False


toSortedList : PriorityQueue comparable a -> List a
toSortedList (PriorityQueue queue) =
    PairingHeap.toSortedList queue
        |> List.map Tuple.second
