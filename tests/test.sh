#!/usr/bin/env bash

set -eo pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

declare -a opts

opts=(
  -sL
  -H 'Content-Type: application/json'
)

curl "${opts[@]}" http://localhost:8000/healthcheck | python3 -m json.tool

curl "${opts[@]}" \
  --data @"${DIR}"/fixtures/sample.json http://localhost:8000/add | python3 -m json.tool

curl "${opts[@]}" localhost:8000/getall | python3 -m json.tool

#curl "${opts[@]}" \
#    -k -D- -H 'Host: app.foo.bar' https://"$(terraform -chdir='./terraform' output -raw alb_hostname)"
