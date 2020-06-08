#!/usr/bin/env bash

update() {
    local local_version
    # TODO BASE  main
    [ -f "$BASE"/.version ] && local_version=$(cat "$BASE"/.version) || local_version="UNKOWN"

    local remote_version

    # TODO duplicate with install
    local latest # metadata for latest release
    latest=$(curl -s https://api.github.com/repos/yoosiba/mrh/releases/latest)
    remote_version=$(echo "$latest" | jq -r '.tag_name')

    if [ "$local_version" != "$remote_version" ]; then
        echo "update $local_version -> $remote_version"
        #pushd "$BASE"/.. >/dev/null || exit 52
        pushd "$BASE"/.. || exit 52
        curl -fsSL https://raw.githubusercontent.com/yoosiba/mrh/master/src/installer.bash | bash
        popd || exit 51
        #popd >/dev/null || exit 51
    else
        echo "using lates version $local_version"
    fi
}
