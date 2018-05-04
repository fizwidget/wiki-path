#!/bin/bash

git checkout gh-pages
git merge master -m "Merging master"
./build.sh
git commit -am "Updating build"
git push
git checkout master