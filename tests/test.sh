#!/usr/bin/env bash

set -eo pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

declare -a opts

opts=(
  -sL
  -H 'Content-Type: application/json'
)

curl "${opts[@]}" \
  --data @"${DIR}"/sample.json http://localhost:8000/add | python -m json.tool

curl "${opts[@]}" \
  localhost:8000/getall | python -m json.tool


aws --no-cli-pager --endpoint-url=http://localhost:4566 dynamodb list-tables
