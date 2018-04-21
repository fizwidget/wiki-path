# Wikipedia Game in Elm

A 100% frontend implementation of the "Wikipedia game". It'll find a path between any two Wikipedia articles. Still a work in progress!

https://en.wikipedia.org/wiki/Wikipedia:Wiki_Game

TODO:
* Fix redirect dead-end problem (using A* search?).
* Switch to elm-css.
* Completely decouple the phases?
* Improve naming (start/end -> origin/destination?).
* Dissalow repeat visits?

Fairy Wren
Birds
Cats
Lions
Lion King
Timone & Pumba


# Problem

If destination is a redirect page, heursitic will have nothing to work with.

Solution: automatically follow through to "real" page before setting destination.

# Algorithm

## Article heuristic

Count the number of occurences of the article title in the destination article's content.

## Path heuristic

Article heuristic + (0.8 * existing path heuristic).