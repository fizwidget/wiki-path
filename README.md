# Wikipedia Game in Elm

A 100% frontend implementation of the "Wikipedia game". It'll find a path between any two Wikipedia articles. Still a work in progress!

https://en.wikipedia.org/wiki/Wikipedia:Wiki_Game

TODO:
* Perform requests in parallel?
* Switch to elm-css.
* Completely decouple the phases?
* Completely disallow repeat visits to nodes?

Fairy Wren
Birds
Cats
Lions
Lion King
Timone & Pumba

# Problem

Regex is sub-optional? It won't find occurences that are quoted, have a trailing colon, etc.

# Algorithm

Current algorithm finds longer paths in some situations, e.g. Foo -> Bar.

Foo -> Foobar -> Bill Gates -> United States -> Blues -> Nightclub -> Bar.

^ best seen so far.

## Article heuristic

Count the number of occurences of the article title in the destination article's content.

## Path heuristic

Article heuristic + (0.8 * existing path heuristic).