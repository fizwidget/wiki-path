#!/bin/bash

if [[ "$1" = '--watch' ]]
then
    elm-live src/Main.elm --output=build/elm.js --pushstate
else
    elm-make --warn src/Main.elm --output build/elm.js
fi