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
  unzip ./bin/mrh.zip -d./bin/mrh
  ./bin/mrh/mrh.bash
  ./bin/mrh/mrh.bash -ud
}

dist() {
  build_dist "$@"
  test_dist
}
