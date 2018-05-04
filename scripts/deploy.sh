#!/bin/bash

set -e

git checkout gh-pages
git merge master
./build.sh
git commit -am "Updating build"
git push
git checkout master