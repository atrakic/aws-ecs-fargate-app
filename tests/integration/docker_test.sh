#!/usr/bin/env bash
set -e
docker run --rm --name ci -p 8000:8000 \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test -d ghcr.io/atrakic/aws-publisher:latest
sleep 1
curl --connect-timeout 10 --retry-delay 5 --retry 5 localhost:8000
docker stop ci
