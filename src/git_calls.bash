#!/usr/bin/env bash

# colors https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# branches # https://stackoverflow.com/questions/4950725/how-can-i-see-which-git-branches-are-tracking-which-remote-upstream-branch

function git_status() {
    local repo=$1
    local root=$2

    local at_up="@{upstream}"

    local CLR_RED=1
    local CLR_GRN=2
    local CLR_YLW=3
    local CLR_BLU=4
    local CLR_MGN=5
    local CLR_CYN=6

    pushd "$repo" >/dev/null || exit 3
    git fetch &>/dev/null
    #git fetch
    local PR_CLR=$CLR_MGN
    local BR_CLR=$CLR_GRN
    #local UP_CLR=$CLR_GRN
    local PROJECT
    PROJECT=$(realpath --relative-to="${root}" "$(pwd)")
    local BRANCH
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    local REMOTE
    REMOTE=$(git rev-parse --abbrev-ref $at_up 2>/dev/null)
    if [[ $REMOTE != "$at_up" ]]; then
        local UPSTREAM
        UPSTREAM=$(git rev-list $at_up..HEAD --count)
        local DOWNSTREAM
        DOWNSTREAM=$(git rev-list HEAD..$at_up --count)
        local UP_CLR=$BR_CLR
        local DO_CLR=$BR_CLR

        if [[ $UPSTREAM != 0 ]]; then
            local UP_CLR=$CLR_YLW
        fi

        if [[ $DOWNSTREAM != 0 ]]; then
            local DO_CLR=$CLR_YLW
        fi

        if [[ $BRANCH != "master" ]]; then
            local PR_CLR=$CLR_BLU
            local BR_CLR=$CLR_YLW
        fi
        echo -e "$(tput setaf $PR_CLR)$PROJECT$(tput sgr 0) $(tput setaf $BR_CLR)$BRANCH$(tput sgr 0)[$(tput bold)$(tput setaf $UP_CLR)$UPSTREAM$(tput sgr 0)..$(tput bold)$(tput setaf $DO_CLR)$DOWNSTREAM$(tput sgr 0)]$(tput setaf $BR_CLR)$REMOTE$(tput sgr 0)"
    else
        local PR_CLR=$CLR_CYN
        local BR_CLR=$CLR_RED
        echo -e "$(tput setaf $PR_CLR)$PROJECT$(tput sgr 0) $(tput setaf $BR_CLR)$BRANCH$(tput sgr 0) [NO UPSTREAM]"
    fi
}
