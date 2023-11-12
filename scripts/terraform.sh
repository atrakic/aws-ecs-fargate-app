#!/usr/bin/env bash
set -o errexit

BASE_REF="$(git rev-parse --abbrev-ref HEAD)"

ARGS=("-chdir=terraform")

aws sts get-caller-identity | cat -

terraform "${ARGS[*]}" init -upgrade -reconfigure

if [ "$1" == "clean" ]; then
  terraform "${ARGS[*]}" destroy -var-file fixtures.tfvars
else
  terraform "${ARGS[*]}" validate -compact-warnings
  terraform "${ARGS[*]}" plan -compact-warnings -var-file fixtures.tfvars -out "$BASE_REF".tfplan
  terraform "${ARGS[*]}" apply -compact-warnings "$BASE_REF".tfplan
  terraform "${ARGS[*]}" show
fi
