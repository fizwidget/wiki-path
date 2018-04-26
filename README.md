# WikiLinks

WikiLinks is a frontend [Elm](http://elm-lang.org/) implementation of the [Wikipedia game](https://en.wikipedia.org/wiki/Wikipedia:Wiki_Game). It'll try to find a path between any two Wikipedia articles.

[Have a play with it here!](https://fizwidget.github.io/wikipedia-game/index.html)

- - -

TODOs:
* Improve performance of `isUnvisited` check by using a set.
* Improve performance by performing requests in parallel.
* Experiment with improved pathfinding by penalising longer paths.
* Loading spinner for pathfinding view.
* Improve readability of `Pathfinding.Update` by combining `Path` and `Article` somehow?
* Completely decouple the different pages from each other.
* Come up with a better heuristic regex (current one doesn't handle quotes, trailing colon, etc).
* Still something weird with redirects going on? E.g. "Banana -> The Chronicles of Narnia" visits the same article twice.
* Struggles with "World -> Hello" for some reason?