# TODO

* Improve handling of "too many requests" case.
* Make `Path` have start and end fields ("make impossible states impossible").
    * End should optionally be an Article.
    * Improve readability of `Pathfinding.Update` by combining `Path` and `Article` somehow?
* Fix heading font size for mobile devices.
* Improve performance of `isUnvisited` check by using a set.
* Experiment with improved pathfinding by penalising longer paths.
* Come up with a better heuristic regex (current one doesn't handle quotes, trailing colon, etc).