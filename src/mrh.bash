#!/usr/bin/env bash

VERBOSE="${VERBOSE:-false}"

TO_SCAN=$(pwd)

get_mrh_folder() {
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
        DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
    echo "$DIR"
}

BASE=$(get_mrh_folder)
# shellcheck source=./progress_bar.bash
source "$BASE"/progress_bar.bash
# shellcheck source=./find_repos.bash
source "$BASE"/find_repos.bash
# shellcheck source=./git_calls.bash
source "$BASE"/git_calls.bash

main() {
    enable_trapping   # Make sure that the progress bar is cleaned up when user presses ctrl+c
    setup_scroll_area # Create progress bar

    local repos=()
    find_git_roots repos "$TO_SCAN"

    local progress=0
    local len=${#repos[@]}
    for repo in "${repos[@]}"; do
        progress=$(echo - | awk "{print $progress + ((1.0 / $len)*100)}")
        draw_progress_bar "$progress"
        echo -en "@ ${repo} \r"
        git_status "$repo" "$TO_SCAN"
    done
    destroy_scroll_area
}

main
