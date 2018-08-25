# WikiPath

This is an implementation of the [Wikipedia game](https://en.wikipedia.org/wiki/Wikipedia:Wiki_Game) in the [Elm programming language](http://elm-lang.org/). It'll try its best to find a path between any two Wikipedia articles, sometimes with amusing results.

[Have a play with it here!](https://fizwidget.github.io/wiki-path/index.html) (｡◕‿◕｡)

## How does it work?

Pathfinding is done in the browser using requests to Wikipedia's REST API. An unguided breadth-first search would be impractical, as far too many network requests would be needed.

The pathfinding algorithm is an A* graph search with a non-admissible heuristic. It attempts to guess how closely related articles are to the destination article. It may not necessarily find the *optimal* path, but it usually finds *some* path in a relatively short amount of time.
