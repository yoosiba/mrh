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

  pwd
  ls ./

  FILE=$(find . -name "mrh.zip")
  echo "$FILE"
  RES=$(
    curl -s "https://uploads.github.com/repos/yoosiba/mrh/releases/$ID/assets?name=mrh.zip" \
      -X POST \
      -H "authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: $(file -b --mime-type "$FILE")" \
      --data-binary @"$FILE"
  )

  echo "___________"
  echo "$RES" | jq '.id' || (echo "$ID" && exit 33)
  echo "___________"

}

upload_dist() {
  echo "todo upload zip"
}

create_release
upload_dist
