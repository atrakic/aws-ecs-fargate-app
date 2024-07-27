#!/usr/bin/env bash

set -eo pipefail

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
aws "${opts[@]}" sns list-topics
aws "${opts[@]}" sns list-subscriptions
aws "${opts[@]}" sqs list-queues
#aws "${opts[@]}" s3api list-buckets
#aws "${opts[@]}" acm list-certificates --max-items 10
