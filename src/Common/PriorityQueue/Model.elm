module Common.PriorityQueue.Model
    exposing
        ( PriorityQueue
        , Priority
        , empty
        , insert
        , removeHighestPriority
        , removeHighestPriorities
        , getHighestPriority
        , isEmpty
        , toSortedList
        )

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


removeHighestPriorities : PriorityQueue a -> Int -> ( List a, PriorityQueue a )
removeHighestPriorities priorityQueue howMany =
    removeHighestPrioritiesInternal priorityQueue howMany []
        |> Tuple.mapFirst (List.filterMap identity)


removeHighestPrioritiesInternal : PriorityQueue a -> Int -> List (Maybe a) -> ( List (Maybe a), PriorityQueue a )
removeHighestPrioritiesInternal priorityQueue howMany values =
    if howMany > 0 then
        let
            ( value, updatedPriorityQueue ) =
                removeHighestPriority priorityQueue
        in
            removeHighestPrioritiesInternal updatedPriorityQueue (howMany - 1) (value :: values)
    else
        ( values, priorityQueue )


getHighestPriority : PriorityQueue a -> Maybe a
getHighestPriority (PriorityQueue pairingHeap) =
    PairingHeap.findMin pairingHeap |> Maybe.map Tuple.second


isEmpty : PriorityQueue a -> Bool
isEmpty (PriorityQueue pairingHeap) =
    PairingHeap.findMin pairingHeap
        |> Maybe.map (always True)
        |> Maybe.withDefault False


toSortedList : PriorityQueue a -> List a
toSortedList (PriorityQueue pairingHeap) =
    PairingHeap.toSortedList pairingHeap
        |> List.map Tuple.second
