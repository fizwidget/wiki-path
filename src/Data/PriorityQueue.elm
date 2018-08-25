module Data.PriorityQueue
    exposing
        ( PriorityQueue
        , Priority
        , empty
        , isEmpty
        , insert
        , highestPriority
        , removeHighestPriority
        , removeHighestPriorities
        , inPriorityOrder
        )

import PairingHeap exposing (PairingHeap)


type PriorityQueue a
    = PriorityQueue (PairingHeap Priority a)


type alias Priority =
    Float


empty : PriorityQueue a
empty =
    PriorityQueue PairingHeap.empty


isEmpty : PriorityQueue a -> Bool
isEmpty priorityQueue =
    highestPriority priorityQueue
        |> Maybe.map (always False)
        |> Maybe.withDefault True


insert : PriorityQueue a -> (a -> Priority) -> List a -> PriorityQueue a
insert (PriorityQueue pairingHeap) getPriority values =
    let
        -- Negating the priorities because `PairingHeap` is a min-heap, but we want
        -- to treat it as a max-heap (so the highest priority is at the top).
        withNegatedPriorities =
            values
                |> List.map (\value -> ( getPriority value, value ))
                |> List.map (Tuple.mapFirst negate)
    in
        List.foldl PairingHeap.insert pairingHeap withNegatedPriorities
            |> PriorityQueue


highestPriority : PriorityQueue a -> Maybe a
highestPriority (PriorityQueue pairingHeap) =
    PairingHeap.findMin pairingHeap
        |> Maybe.map Tuple.second


removeHighestPriority : PriorityQueue a -> ( Maybe a, PriorityQueue a )
removeHighestPriority (PriorityQueue pairingHeap) =
    ( PairingHeap.findMin pairingHeap |> Maybe.map Tuple.second
    , pairingHeap |> PairingHeap.deleteMin |> PriorityQueue
    )


removeHighestPriorities : PriorityQueue a -> Int -> ( List a, PriorityQueue a )
removeHighestPriorities priorityQueue howMany =
    removeHighestPrioritiesHelper priorityQueue howMany []


removeHighestPrioritiesHelper : PriorityQueue a -> Int -> List a -> ( List a, PriorityQueue a )
removeHighestPrioritiesHelper priorityQueue howMany removedSoFar =
    if howMany <= 0 then
        ( removedSoFar, priorityQueue )
    else
        let
            ( removedValue, updatedPriorityQueue ) =
                removeHighestPriority priorityQueue

            removedValues =
                removedValue
                    |> Maybe.map (\value -> value :: removedSoFar)
                    |> Maybe.withDefault removedSoFar
        in
            removeHighestPrioritiesHelper updatedPriorityQueue (howMany - 1) removedValues


inPriorityOrder : PriorityQueue a -> List a
inPriorityOrder (PriorityQueue pairingHeap) =
    PairingHeap.toSortedList pairingHeap
        |> List.map Tuple.second
