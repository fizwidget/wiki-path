module Common.PriorityQueue.Model
    exposing
        ( PriorityQueue
        , Priority
        , empty
        , insert
        , removeHighestPriority
        , removeHighestPriorities
        , getHighestPriority
        , size
        , isEmpty
        , toSortedList
        )

import PairingHeap exposing (PairingHeap)


type PriorityQueue a
    = PriorityQueue
        { pairingHeap : PairingHeap Priority a
        , size : Int
        }


type alias Priority =
    Float


empty : PriorityQueue a
empty =
    PriorityQueue
        { pairingHeap = PairingHeap.empty
        , size = 0
        }


insert : PriorityQueue a -> (a -> Priority) -> List a -> PriorityQueue a
insert (PriorityQueue { pairingHeap, size }) getPriority values =
    let
        getNegatedPriority =
            getPriority >> negate

        withNegatedPriority =
            \value -> ( getNegatedPriority value, value )

        valuesWithNegatedPriorities =
            List.map withNegatedPriority values

        updatedPairingHeap =
            List.foldl PairingHeap.insert pairingHeap valuesWithNegatedPriorities
    in
        PriorityQueue
            { pairingHeap = updatedPairingHeap
            , size = size + List.length values
            }


getHighestPriority : PriorityQueue a -> Maybe a
getHighestPriority (PriorityQueue { pairingHeap }) =
    PairingHeap.findMin pairingHeap
        |> Maybe.map Tuple.second


removeHighestPriority : PriorityQueue a -> ( Maybe a, PriorityQueue a )
removeHighestPriority (PriorityQueue { pairingHeap, size }) =
    let
        highestPriorityValue =
            PairingHeap.findMin pairingHeap
                |> Maybe.map Tuple.second

        updatedPriorityQueue =
            PriorityQueue
                { pairingHeap = PairingHeap.deleteMin pairingHeap
                , size = max 0 (size - 1)
                }
    in
        ( highestPriorityValue, updatedPriorityQueue )


removeHighestPriorities : PriorityQueue a -> Int -> ( List a, PriorityQueue a )
removeHighestPriorities priorityQueue howMany =
    let
        helper priorityQueue howMany removedValues =
            if howMany > 0 then
                let
                    ( value, updatedPriorityQueue ) =
                        removeHighestPriority priorityQueue
                in
                    helper updatedPriorityQueue (howMany - 1) (value :: removedValues)
            else
                ( removedValues, priorityQueue )
    in
        helper priorityQueue howMany []
            |> Tuple.mapFirst (List.filterMap identity)


size : PriorityQueue a -> Int
size (PriorityQueue { size }) =
    size


isEmpty : PriorityQueue a -> Bool
isEmpty priorityQueue =
    size priorityQueue == 0


toSortedList : PriorityQueue a -> List a
toSortedList (PriorityQueue { pairingHeap }) =
    PairingHeap.toSortedList pairingHeap
        |> List.map Tuple.second
