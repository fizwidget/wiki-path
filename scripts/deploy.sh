#!/bin/bash

printf "Checking out deployment branch...\n"
git checkout gh-pages

printf "Merging master into deployment branch\n"
git merge master -m "Merging master"

printf "Building...\n"
./build.sh

printf "Comitting new assets...\n"
git commit -am "Updating build"

printf "Pushing built result...\n"
git push -f

printf "Checking out master...\n"
git checkout master

printf "Deployment successful (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"