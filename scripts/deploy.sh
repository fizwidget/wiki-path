#!/bin/bash

echo "Checking out deployment branch...\n"
git checkout gh-pages

echo "Merging master into deployment branch\n"
git merge master -m "Merging master"

echo "Building...\n"
./build.sh

echo "Comitting new assets...\n"
git commit -am "Updating build"

echo "Pushing built result...\n"
git push -f

echo "Checking out master...\n"
git checkout master

echo "Deployment successful (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"