#!/bin/bash

#####################################
# $ git checkout master
# Switched to branch 'master'
# $ git merge --no-ff hotfix-1.2.1
# Merge made by recursive.
# (Summary of changes)
# $ git tag -a 1.2.1
#####################################



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

# function parse_version() {
#     # '/(?:(?<major>(?:0|[1-9](?:(?:0|[1-9])+)*))[.](?<minor>(?:0|[1-9](?:(?:0|[1-9])+)*))[.](?<patch>(?:0|[1-9](?:(?:0|[1-9])+)*)))$/'
# }

# DEMO
if [ -f VERSION ]; then
    GIT_BRANCH=$(parse_git_branch)$(parse_git_hash)
    GIT_VERSION=$(echo $GIT_BRANCH | sed 's/.*hotfix-\([^ ]*\).*/\1/')
    git checkout master
    git merge --no-ff $GIT_BRANCH
    # git tag -a $GIT_VERSION
    git tag -a -m "Tagging version $GIT_VERSION" "v$GIT_VERSION"
    git push origin --tags
    read -p "Do you want to delete $GIT_BRANCH branch? [y]" RESPONSE
    if [ "$RESPONSE" = "" ]; then RESPONSE="y"; fi
    if [ "$RESPONSE" = "y" ]; then
        git branch -d $GIT_BRANCH
    fi
else
    echo "Could not find a VERSION file"
fi