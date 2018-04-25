module Common.Model.PriorityQueue exposing (PriorityQueue, Priority, empty, insert, removeHighestPriority, isEmpty, toSortedList)

import PairingHeap exposing (PairingHeap)


type PriorityQueue a
    = PriorityQueue (PairingHeap Priority a)


type alias Priority =
    Float


empty : PriorityQueue a
empty =
    PriorityQueue PairingHeap.empty


insert : PriorityQueue a -> (a -> Priority) -> List a -> PriorityQueue a
insert (PriorityQueue pairingHeap) getPriority values =
    let
        getNegatedPriority value =
            -(getPriority value)

        withNegatedPriority =
            \value -> ( getNegatedPriority value, value )

        valuesWithNegatedPriorities =
            List.map withNegatedPriority values
    in
        List.foldl PairingHeap.insert pairingHeap valuesWithNegatedPriorities |> PriorityQueue


removeHighestPriority : PriorityQueue a -> ( Maybe a, PriorityQueue a )
removeHighestPriority (PriorityQueue pairingHeap) =
    ( PairingHeap.findMin pairingHeap |> Maybe.map Tuple.second
    , PairingHeap.deleteMin pairingHeap |> PriorityQueue
    )


isEmpty : PriorityQueue a -> Bool
isEmpty (PriorityQueue pairingHeap) =
    PairingHeap.findMin pairingHeap
        |> Maybe.map (always True)
        |> Maybe.withDefault False


toSortedList : PriorityQueue a -> List a
toSortedList (PriorityQueue pairingHeap) =
    PairingHeap.toSortedList pairingHeap
        |> List.map Tuple.second
