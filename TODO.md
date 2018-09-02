# TODO

## Pathfinding
* Backtrack from destination in addition to searching from origin.
* Fetch multiple articles per network call.
* Favour longer string matches, and strings that match links?
* Experiment with penalising longer paths?

## Views
* Move away from Bootstrap?

## Type safety
* Phantom types for complete/incomplete paths?

## Refactoring
* Improve readability of `Pathfinding.Update` by combining `Path` and `Article` somehow?
    * `Path a` & `Path.map` to model this?