#!/usr/bin/env bash

set -eo pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

declare -a opts

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-test}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-test}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}

opts=(
  --no-cli-pager
  --endpoint-url=http://localhost:4566
)

aws "${opts[@]}" sts get-caller-identity | cat -
aws "${opts[@]}" dynamodb list-tables
aws "${opts[@]}" acm list-certificates --max-items 10

opts=(
  -sL
  -H 'Content-Type: application/json'
)

curl "${opts[@]}" \
  --data @"${DIR}"/sample.json http://localhost:8000/add | python3 -m json.tool

curl "${opts[@]}" \
  localhost:8000/getall | python3 -m json.tool

#curl "${opts[@]}" \
#    -k -D- -H 'Host: app.foo.bar' https://"$(terraform -chdir='./terraform' output -raw alb_hostname)"
