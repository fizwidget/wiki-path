#!/bin/bash

echo "> Checking out deployment branch..."
git checkout gh-pages

echo "> Merging master into deployment branch"
git merge master -m "Merging master"

echo "> Building..."
./build.sh

echo "> Pushing built result..."
git commit -am "Updating build"
git push
git checkout master

echo "Deployment successful (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"