#!/bin/bash

# this script will display the current version, automatically
# suggest a "minor" version update, and ask for input to use
# the suggestion, or a newly entered value.

# checks if branch has something pending
function parse_git_dirty() {
  git diff --quiet --ignore-submodules HEAD 2>/dev/null; [ $? -eq 1 ] && echo "*"
}

# gets the current git branch
function parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

# get last commit hash prepended
function parse_git_hash() {
  git rev-parse --short HEAD 2> /dev/null | sed "s/\(.*\)//"
}

GIT_BRANCH=$(parse_git_branch)$(parse_git_hash)
GIT_VERSION=$(echo $GIT_BRANCH | sed 's/.*hotfix-\([^ ]*\).*/\1/')

# checkout on master branch, merge and tag
git checkout master
git merge --no-ff $GIT_BRANCH
echo "Tagging version : $GIT_VERSION"
git tag -a -m "Tagging version $GIT_VERSION" "v$GIT_VERSION"

# push on master and tags
git push origin master -f
git push origin --tags

# ask for deleting hotfix-branch
read -p "Do you want to delete $GIT_BRANCH branch? [y]" RESPONSE
if [ "$RESPONSE" = "" ]; then RESPONSE="y"; fi
if [ "$RESPONSE" = "y" ]; then
    git branch -d $GIT_BRANCH
fi