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

  echo "==============="
  echo "$DATA" | jq '.' || echo "$DATA" && exit 1
  echo "==============="

  RES=$(
    curl -s 'https://api.github.com/repos/yoosiba/mrh/releases' \
      -X POST \
      -H "authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: application/json; charset=utf-8" \
      --data-binary @- <<EOF
    "$DATA"
EOF
  )

  echo "-----------"
  echo "$RES" | jq '.' || echo "$RES" && exit 1
  echo "-----------"
}

upload_dist() {
  echo "todo upload zip"
}

create_release
upload_dist
