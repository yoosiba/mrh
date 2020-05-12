#!/usr/bin/env bash

create_release() {
  NAME="v1.0.$(date "+%Y%m%d%H%M%S")"
  COMMITISH="create_releases"
  DESC="$COMMITISH $NAME"
  DATA=$(
    jq -n --arg name "$NAME" --arg desc "$DESC" --arg ish "$COMMITISH" \
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
  echo "$DATA" | jq '.' || (echo "$DATA" && exit 11)
  echo "   "

  local res
  res=$(
    curl -s 'https://api.github.com/repos/yoosiba/mrh/releases' \
      -X POST \
      -H "authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: application/json; charset=utf-8" \
      --data-binary "$DATA"
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
  RES=$(
    curl -s "https://uploads.github.com/repos/yoosiba/mrh/releases/$id/assets?name=mrh.zip" \
      -X POST \
      -H "authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: $(file -b --mime-type "$bin")" \
      --data-binary @"$bin"
  )

  echo "finished upload"
  echo "$RES" | jq '.' || (echo "$RES" && exit 33)
}

echo "sha $GITHUB_SHA"
echo "ref $GITHUB_REF"

create_release
