# TODO

* Improve performance of `isUnvisited` check by using a set.
* Improve performance by performing requests in parallel.
* Experiment with improved pathfinding by penalising longer paths.
* Improve readability of `Pathfinding.Update` by combining `Path` and `Article` somehow?
* Come up with a better heuristic regex (current one doesn't handle quotes, trailing colon, etc).
* Still something weird with redirects going on? E.g. "Banana -> The Chronicles of Narnia" visits the same article twice.
* Struggles with "World -> Hello" for some reason?