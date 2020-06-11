#!/usr/bin/env bash

build_dist() {
  local ver #version info
  ver="$1"

  rm -rf ./bin
  mkdir ./bin

  zip ./bin/mrh.zip ./src/*.bash -j

  echo "$ver" >./bin/.version
  zip -r ./bin/mrh.zip ./bin/.version -j
}

test_dist() {
  mkdir ./bin/mrh_dist_test
  cp ./bin/mrh.zip ./bin/mrh_dist_test/
  pushd ./bin/mrh_dist_test >/dev/null || exit 62
  ls -la
  unzip ./mrh.zip -d .
  ls -la
  ls -./mrh/
  ./mrh/mrh.bash
  ./mrh/mrh.bash -ud
  popd >/dev/null || exit 61
  ls -la
}

dist() {
  build_dist "$@"
  test_dist
}
