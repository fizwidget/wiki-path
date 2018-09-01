module OrderedSet exposing (OrderedSet, inOrder, insert, member, singleton)

import Set exposing (Set)


type OrderedSet comparable
    = OrderedSet (Set comparable) (List comparable)


singleton : comparable -> OrderedSet comparable
singleton value =
    OrderedSet (Set.singleton value) (List.singleton value)


member : comparable -> OrderedSet comparable -> Bool
member value (OrderedSet set _) =
    Set.member value set


insert : comparable -> OrderedSet comparable -> OrderedSet comparable
insert value (OrderedSet set list) =
    OrderedSet (Set.insert value set) (value :: list)


inOrder : OrderedSet comparable -> List comparable
inOrder (OrderedSet _ list) =
    list
