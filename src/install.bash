#!/usr/bin/env bash

check_dep() {
    local output #capture for processing
    if output=$("$@" 2>&1); then
        #TODO check concrete versions
        output=$(echo "$output" | head -n 1)
        echo -e " \u2611 $output"
    else
        echo -e " \u2612 error checking dependecy:: $*"
        echo -e "$output"
        exit $?
    fi
}

check_deps() {
    echo "checking dependencies"
    check_dep 'bash' '--version'
    check_dep 'curl' '--version'
    check_dep 'jq' '--version'
    check_dep 'unzip' '-v'
    check_dep 'git' '--version'
    check_dep 'md5sum' '--version'
    check_dep 'bc' '--version'
}

install() {
    check_deps
    echo ""
    local latest # metadata for latest release
    latest=$(curl -s https://api.github.com/repos/yoosiba/mrh/releases/latest)
    local download_url # download url for resolved latest binary
    download_url=$(echo "$latest" | jq -r '.assets[] | select(.name | test("mrh.zip")) | .browser_download_url')
    echo "download_url $download_url"
    curl -sOJL "$download_url"
    if [ -d ./mrh ]; then
        rm -rf ./mrh
    fi
    unzip -qq ./mrh.zip -d ./mrh
    rm ./mrh.zip
    echo "finished instalation"
}

install
