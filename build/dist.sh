#!/usr/bin/env bash

TERM=xterm

build_dist() {
  rm -rf ./bin
  mkdir ./bin
  zip ./bin/mrh.zip ./src/*.bash -j
}

test_dist() {
  unzip ./bin/mrh.zip -d./bin/mrh
  ./bin/mrh/mrh.bash || exit 1
}

build_dist
test_dist
