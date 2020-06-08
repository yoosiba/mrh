#!/usr/bin/env bash

pushd src >/dev/null || exit 41
shellcheck -- *.bash
popd >/dev/null || exit 42
pushd build >/dev/null || exit 43
shellcheck -- *.sh
popd >/dev/null || exit 44
