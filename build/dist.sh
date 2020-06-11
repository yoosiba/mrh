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
  unzip ./bin/mrh.zip -d./bin/mrh_dist_test
  ./bin/mrh_dist_path/mrh.bash
  ./bin/mrh_dist_path/mrh.bash -ud
}

dist() {
  build_dist "$@"
  test_dist
}
