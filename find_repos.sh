#!/usr/bin/env bash

#spin scan
endless_spin() {
    while :; do for s in / - \\ \|; do
        printf "\r%s" "$s"
        #sleep: cannot read realtime clock: Invalid argument
        #sleep 1s
    done; done
}

function abs_path() {
    if [[ -d "$1" ]]; then
        pushd "$1" >/dev/null || exit 3
        cd ..
        local x
        x=$(pwd)
        popd >/dev/null || exit 3
        echo "$x"
    elif [[ -e $1 ]]; then
        echo "$1" but how? >&2
        return 127
        pushd "$(dirname "$1")" >/dev/null || exit 3
        echo "$(pwd)/$(basename "$1")"
        popd >/dev/null || exit 3
    else
        echo "$1" does not exist! >&2
        return 127
    fi
}

function find_git_roots() {
    local -n gitRoots=$1
    local root=$2

    endless_spin &
    local endless_spin=$!

    local gitFolders=()
    readarray -d $'\0' gitFolders < <(find "$root" -name .git -print0)

    #sorting might be obsolete, as find returns sorted result
    readarray -t sortedGitFolders < <(printf '%s\0' "${gitFolders[@]}" | sort -z | xargs -0n1)
    if $VERBOSE; then
        echo -e "-------------\ngitFolders"
        for gitFolder in "${sortedGitFolders[@]}"; do
            echo " " "$gitFolder"
        done
    fi

    for gitFolder in "${sortedGitFolders[@]}"; do
        readarray -t -O "${#gitRoots[@]}" gitRoots < <(abs_path "$gitFolder")
    done

    if $VERBOSE; then
        echo -e "-----------\ngitRoots"
        for gitRoot in "${gitRoots[@]}"; do
            echo " " "$gitRoot"
        done
    fi

    # kill spinner and cleanup
    kill $endless_spin >/dev/null 2>&1
    printf "\r"
}
