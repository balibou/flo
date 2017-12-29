#!/bin/bash

# this script will create a hotfix branch

# get package version
prop="version"
PACKAGE_VERSION="$(node -pe "require('./package.json')['$prop']")"

# define hotfix version
BASE_STRING=$PACKAGE_VERSION
BASE_LIST=(`echo $BASE_STRING | tr '.' ' '`)
V_MAJOR=${BASE_LIST[0]}
V_MINOR=${BASE_LIST[1]}
V_PATCH=${BASE_LIST[2]}
echo "Current version : $BASE_STRING"
V_PATCH=$((V_PATCH + 1))
SUGGESTED_VERSION="$V_MAJOR.$V_MINOR.$V_PATCH"
read -p "Enter a version number [Suggested (press Enter): $SUGGESTED_VERSION]: " INPUT_STRING
if [ "$INPUT_STRING" = "" ]; then
    INPUT_STRING=$SUGGESTED_VERSION
fi

# checkout hotfix branch
git checkout -b hotfix-$INPUT_STRING master

# bump package version
yarn version --new-version $INPUT_STRING --no-git-tag-version
git commit -a -m "Version bump to $INPUT_STRING"

# ask for hotfix commit
echo "Commit your hotfix on this branch then run yarn post-hotfix"