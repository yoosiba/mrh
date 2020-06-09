#!/usr/bin/env bash

# let workflow find dist script
# shellcheck source=./dist.sh
source "$(find . -name "dist.sh" -print)" || exit 44

create_release() {
  local version
  version="$1"

  local -n rel_id=$2

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

  rel_id=$(echo "$res" | jq '.id' || (echo "$res" && exit 22))
  echo "created release $rel_id"
}

upload_dist() {
  local rel_id=$1

  local bin
  bin=$(find . -name "mrh.zip" -print)
  echo "upload " "$bin" " to " "$rel_id"
  [[ -f "$bin" ]] || (echo "can't locate dist file $bin" && exit 77)
  echo "uploading $bin to release id $rel_id"
  local res
  res=$(
    curl -s "https://uploads.github.com/repos/yoosiba/mrh/releases/$rel_id/assets?name=mrh.zip" \
      -X POST \
      -H "authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: $(file -b --mime-type "$bin")" \
      --data-binary @"$bin"
  )

  echo "finished upload"
  echo "$res" | jq '.' || (echo "$res" && exit 33)
}

release() {
  local version
  version="$(date "+%Y%m%d%H%M%S")"
  dist "$version"

  local release_id
  release_id="dummy"
  create_release "$version" release_id
  upload_dist "$release_id"

}

release
