module PriorityQueue exposing
    ( Priority
    , PriorityQueue
    , empty
    , highestPriority
    , inPriorityOrder
    , insert
    , isEmpty
    , removeHighestPriorities
    , removeHighestPriority
    )

import Heap exposing (Heap, biggest, by)


type PriorityQueue a
    = PriorityQueue (Heap a)


type alias Priority =
    Float


empty : (a -> Priority) -> PriorityQueue a
empty getPriority =
    Heap.empty (biggest |> by getPriority)
        |> PriorityQueue


isEmpty : PriorityQueue a -> Bool
isEmpty (PriorityQueue heap) =
    Heap.isEmpty heap


insert : PriorityQueue a -> List a -> PriorityQueue a
insert (PriorityQueue heap) values =
    List.foldl Heap.push heap values
        |> PriorityQueue


highestPriority : PriorityQueue a -> Maybe a
highestPriority (PriorityQueue heap) =
    Heap.peek heap


removeHighestPriority : PriorityQueue a -> Maybe ( a, PriorityQueue a )
removeHighestPriority (PriorityQueue heap) =
    heap
        |> Heap.pop
        |> Maybe.map (\( value, updatedHeap ) -> ( value, PriorityQueue updatedHeap ))


removeHighestPriorities : PriorityQueue a -> Int -> ( List a, PriorityQueue a )
removeHighestPriorities priorityQueue howMany =
    removeHighestPrioritiesHelper priorityQueue howMany []


removeHighestPrioritiesHelper : PriorityQueue a -> Int -> List a -> ( List a, PriorityQueue a )
removeHighestPrioritiesHelper priorityQueue howMany removedSoFar =
    if howMany <= 0 then
        ( removedSoFar, priorityQueue )

    else
        case removeHighestPriority priorityQueue of
            Just ( removedValue, updatedPriorityQueue ) ->
                removeHighestPrioritiesHelper updatedPriorityQueue (howMany - 1) (removedValue :: removedSoFar)

            Nothing ->
                ( removedSoFar, priorityQueue )


inPriorityOrder : PriorityQueue a -> List a
inPriorityOrder (PriorityQueue heap) =
    Heap.toList heap
