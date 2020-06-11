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
  pwd && ls -la
  mkdir ./bin/mrh_dist_test
  cp ./bin/mrh.zip ./bin/mrh_dist_test/
  # pushd ./bin/mrh_dist_test >/dev/null || exit 62
  pwd && ls -la
  unzip ./bin/mrh_dist_test/mrh.zip -d ./bin/mrh_dist_test/mrh
  pwd && ls -la
  ./bin/mrh_dist_test/mrh/mrh.bash
  ./bin/mrh_dist_test/mrh/mrh.bash -ud
  # popd >/dev/null || exit 61
  pwd && ls -la
  rm -rf ./bin/mrh_dist_test
  pwd && ls -la
}

dist() {
  build_dist "$@"
  test_dist
}
