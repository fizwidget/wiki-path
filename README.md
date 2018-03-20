# Wikipedia Game in Elm

What's the Wikipedia game, you may ask? Pick two random articles, then navigate from one to the other only by following links. This is my attempt at implementing it in Elm ¯\\\_(ツ)_/¯

Still very much a work in progress, I'm learning Elm as I go (•\_•) ( •\_•)>⌐■-■ (⌐■_■)

TODOs:
* Migrate away from the 'transition' pattern, just return another argument from update.
* Implement a spinner on the welcome page.
* Improve performance:
  * Use the `links` section in the returned JSON, avoid parsing the HTML!!!