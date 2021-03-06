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
# shellcheck source=./get_cmd_args.bash
source "$BASE"/get_cmd_args.bash
# shellcheck source=./progress_bar.bash
source "$BASE"/progress_bar.bash
# shellcheck source=./find_repos.bash
source "$BASE"/find_repos.bash
# shellcheck source=./git_calls.bash
source "$BASE"/git_calls.bash
# shellcheck source=./update.bash
source "$BASE"/update.bash

main() {
    declare -A arguments=()
    parse_commandline arguments "$@"

    if [[ ${arguments[UPDATE]} == "on" ]]; then
        update && exit 0 || exit 7
    fi

    enable_trapping   # Make sure that the progress bar is cleaned up when user presses ctrl+c
    setup_scroll_area # Create progress bar

    local repos=()
    find_git_roots repos "$TO_SCAN"

    local progress=0
    local len=${#repos[@]}
    for repo in "${repos[@]}"; do
        progress=$(echo "scale=2; $progress + ((1.0 / $len)*100)" | bc)
        draw_progress_bar "$progress"
        echo -en "@ ${repo} \r"
        git_status "$repo" "$TO_SCAN"
    done
    destroy_scroll_area
}

main "$@"
