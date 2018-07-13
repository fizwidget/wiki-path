# TODO

## Pathfinding
* Backtrack from destination in addition to searching from origin.
* Fetch multiple articles per network call.
* Identify articles by ID instead of by title:
    * `api.php?action=query&generator=links&titles=Main%20Page&prop=info`
    * https://en.wikipedia.org/w/api.php?action=help&modules=query%2Blinks
* Favour longer string matches, and strings that match links.
* Experiment with penalising longer paths.
* Come up with a better heuristic regex (current one doesn't handle quotes, trailing colon, etc).

## Views
* Revamp pathfinding view:
    * Display list of visited titles instead of best path.
    * Fade in the top ones.
    * Should look much less jarring?
* Figure out how to show pending requests?
    * This is why pathfinding view is initially blank.
* Fix heading font size for mobile devices.

## Type safety
* Phantom types:
    * For complete/incomplete paths?
    * Canonical/non-canonical titles?

## Refactoring
* Improve readability of `Pathfinding.Update` by combining `Path` and `Article` somehow?