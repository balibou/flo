#!/bin/bash

# works with a file called VERSION in the current directory,
# the contents of which should be a semantic version number
# such as "1.2.3"

# this script will display the current version, automatically
# suggest a "minor" version update, and ask for input to use
# the suggestion, or a newly entered value.

# once the new version number is determined, the script will
# pull a list of changes from git history, prepend this to
# a file called CHANGES (under the title of the new version
# number) and create a GIT tag.

#########################################################
# $ git checkout -b hotfix-1.2.1 master
# Switched to a new branch "hotfix-1.2.1"
# $ ./bump-version.sh 1.2.1
# Files modified successfully, version bumped to 1.2.1.
# $ git commit -a -m "Bumped version number to 1.2.1"
# [hotfix-1.2.1 41e61bb] Bumped version number to 1.2.1
# 1 files changed, 1 insertions(+), 1 deletions(-)
#########################################################

#####################################
# $ git checkout master
# Switched to branch 'master'
# $ git merge --no-ff hotfix-1.2.1
# Merge made by recursive.
# (Summary of changes)
# $ git tag -a 1.2.1
#####################################

if [ -f VERSION ]; then
    ## PARSING VERSION + DEFINE HOTFIX VERSION
    BASE_STRING=`cat VERSION`
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

    ## BRANCH VERSION HOTFIX
    git checkout -b hotfix-$INPUT_STRING master

    ## BUMP VERSION
    echo "Will set new version to be $INPUT_STRING"
    echo $INPUT_STRING > VERSION
    echo "Version $INPUT_STRING:" > tmpfile
    git log --pretty=format:" - %s" "v$BASE_STRING"...HEAD >> tmpfile
    echo "" >> tmpfile
    echo "" >> tmpfile
    cat CHANGES >> tmpfile
    mv tmpfile CHANGES
    # git add CHANGES VERSION
    yarn version --new-version $INPUT_STRING config set version-git-tag 
    # git commit -m "Version bump to $INPUT_STRING"
    git commit -a -m "Version bump to $INPUT_STRING"

    # git tag -a -m "Tagging version $INPUT_STRING" "v$INPUT_STRING"
    # git push origin --tags

    ## ASK FOR YOUR COMMIT FIX
    echo "Make your hotfix on this branch, commit it then run yarn post-hotfix"
else
    echo "Could not find a VERSION file"
    read -p "Do you want to create a version file and start from scratch? [y]" RESPONSE
    if [ "$RESPONSE" = "" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "Y" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "Yes" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "yes" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "YES" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "y" ]; then
        echo "0.1.0" > VERSION
        echo "Version 0.1.0" > CHANGES
        git log --pretty=format:" - %s" >> CHANGES
        echo "" >> CHANGES
        echo "" >> CHANGES
        git add VERSION CHANGES
        git commit -m "Added VERSION and CHANGES files, Version bump to v0.1.0"
        git tag -a -m "Tagging version 0.1.0" "v0.1.0"
        git push origin --tags
    fi

fi