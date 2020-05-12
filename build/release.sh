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
  echo "$DATA" | jq '.' || (echo "$DATA" && exit 11)
  echo "==============="

  ID=$(
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
  echo "$ID" | jq '.id' || (echo "$ID" && exit 22)
  echo "-----------"

  upload_dist "$ID"
}

upload_dist() {
  local id=$1

  if [ -n "$id" ] && [ "$id" -eq "$id" ]; then
    if [ "$id" -le 0 ]; then
      echo "expected if greater than 0 had $id"
      exit 31
    fi
  else
    echo "expected a numbner had $id"
    exit 32
  fi

  FILE=$(find . -name "mrh.zip" -print)
  echo "$FILE"
  RES=$(
    curl -s "https://uploads.github.com/repos/yoosiba/mrh/releases/$id/assets?name=mrh.zip" \
      -X POST \
      -H "authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: $(file -b --mime-type "$FILE")" \
      --data-binary @"$FILE"
  )

  echo "___________"
  echo "$RES" | jq '.' || (echo "$RES" && exit 33)
  echo "___________"

}

create_release
