#!/bin/bash

git checkout gh-pages
git rebase master
./build.sh
git commit -am "Updating build"
git push
git checkout master
echo "Master branch has been deployed (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"