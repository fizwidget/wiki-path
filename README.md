# WikiPath

"WikiPath" is an implementation of the [Wikipedia game](https://en.wikipedia.org/wiki/Wikipedia:Wiki_Game) in the [Elm programming language](http://elm-lang.org/). It'll try its best to find a path between any two Wikipedia articles, sometimes with amusing results.

[Have a play with it here!](https://fizwidget.github.io/wiki-path/index.html) (｡◕‿◕｡)

## How does it work?

The pathfinding algorithm is essentially an A* graph search with a non-admissible heuristic. This means it may not necessarily find the *optimal* path, but it usually finds *some* path in a relatively short amount of time.

Pathfinding is done client-side, using requests to Wikipedia's REST API. An unguided breadth-first search would be impractical as too many network requests would be needed.