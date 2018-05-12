#!/bin/bash

printf "Checking out deployment branch...\n\n"
git checkout gh-pages

printf "Merging master into deployment branch\n\n"
git merge master -m "Merging master"

printf "Building...\n\n"
./build.sh

printf "Comitting new assets...\n\n"
git commit -am "Updating build"

printf "Pushing built result...\n\n"
git push -f

printf "Checking out master...\n\n"
git checkout master

printf "Deployment successful (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"