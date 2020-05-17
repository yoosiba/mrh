#!/usr/bin/env bash

create_release() {
  local version
  version="v1.0.$(date "+%Y%m%d%H%M%S")"
  local commitish
  commitish="$GITHUB_SHA"
  local desc
  desc="release from $GITHUB_REF ($GITHUB_SHA)"
  local req_data
  req_data=$(
    jq -n --arg name "$version" --arg desc "$desc" --arg ish "$commitish" \
      '{
      "tag_name": $name,
      "target_commitish": $ish,
      "name": $name,
      "body": $desc,
      "draft": false,
      "prerelease": false
    }'
  ) || exit 1

  echo "creating release with data:"
  echo "$req_data" | jq '.' || (echo "$req_data" && exit 11)
  echo "   "

  local res
  res=$(
    curl -s 'https://api.github.com/repos/yoosiba/mrh/releases' \
      -X POST \
      -H "authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: application/json; charset=utf-8" \
      --data-binary "$req_data"
  )

  local id
  id=$(echo "$res" | jq '.id' || (echo "$res" && exit 22))

  upload_dist "$id"
}

upload_dist() {
  local id=$1

  local bin
  bin=$(find . -name "mrh.zip" -print)
  echo "uploading $bin to release id $id"
  local res
  res=$(
    curl -s "https://uploads.github.com/repos/yoosiba/mrh/releases/$id/assets?name=mrh.zip" \
      -X POST \
      -H "authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: $(file -b --mime-type "$bin")" \
      --data-binary @"$bin"
  )

  echo "finished upload"
  echo "$res" | jq '.' || (echo "$res" && exit 33)
}

create_release
