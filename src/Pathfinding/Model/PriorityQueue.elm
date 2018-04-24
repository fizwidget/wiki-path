module Pathfinding.Model.PriorityQueue exposing (PriorityQueue, Priority, empty, insert, removeHighestPriority, isEmpty, toSortedList)

import PairingHeap exposing (PairingHeap)


type PriorityQueue a
    = PriorityQueue (PairingHeap Priority a)


type alias Priority =
    Float


empty : PriorityQueue a
empty =
    PriorityQueue PairingHeap.empty


insert : PriorityQueue a -> (a -> Priority) -> List a -> PriorityQueue a
insert (PriorityQueue queue) getPriority values =
    let
        getNegatedPriority value =
            -(getPriority value)

        withNegatedPriority =
            \value -> ( getNegatedPriority value, value )

        valuesWithNegatedPriorities =
            List.map withNegatedPriority values
    in
        List.foldl PairingHeap.insert queue valuesWithNegatedPriorities |> PriorityQueue


removeHighestPriority : PriorityQueue a -> ( Maybe a, PriorityQueue a )
removeHighestPriority (PriorityQueue queue) =
    ( PairingHeap.findMin queue |> Maybe.map Tuple.second
    , PairingHeap.deleteMin queue |> PriorityQueue
    )


isEmpty : PriorityQueue a -> Bool
isEmpty (PriorityQueue queue) =
    PairingHeap.findMin queue
        |> Maybe.map (always True)
        |> Maybe.withDefault False


toSortedList : PriorityQueue a -> List a
toSortedList (PriorityQueue queue) =
    PairingHeap.toSortedList queue
        |> List.map Tuple.second
