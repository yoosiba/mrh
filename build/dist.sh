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
  unzip ./bin/mrh_dist_test/mrh.zip -d ./bin/mrh_dist_test/mrh

  ./bin/mrh_dist_test/mrh/mrh.bash
  ./bin/mrh_dist_test/mrh/mrh.bash -ud

  rm -rf ./bin/mrh_dist_test
}

dist() {
  build_dist "$@"
  test_dist
}
