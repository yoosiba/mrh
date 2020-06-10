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
        pushd "$BASE"/.. >/dev/null || exit 52
        [[ -d ./mrh ]] || (echo "pre-pdate can't locate " ./mrh && exit 53)
        local pre_checksum # save checksum for update self test
        pre_checksum=$(find ./mrh -type f | sort -u | xargs cat | md5sum | cut -d " " -f1)
        curl -fsSL https://raw.githubusercontent.com/yoosiba/mrh/master/src/install.bash | bash
        [[ -d ./mrh ]] || (echo "post-update can't locate " ./mrh && exit 54)
        local post_checksum # save checksum for update self test
        post_checksum=$(find ./mrh -type f | sort -u | xargs cat | md5sum | cut -d " " -f1)
        [[ "$pre_checksum" == "$post_checksum" ]] || echo "mds did not change $pre_checksum" && exit 55
        popd >/dev/null || exit 51
    else
        echo "using lates version $local_version"
    fi
}
