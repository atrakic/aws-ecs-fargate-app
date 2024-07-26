#!/usr/bin/env bash
set -o errexit

BASE_REF="$(git rev-parse --abbrev-ref HEAD)"

DIR=terraform

ARGS=("-chdir=$DIR")

export TF_IN_AUTOMATION=true
export TF_CLI_ARGS_init="-input=false"


if [ ! -d "$DIR"/.terraform ]; then
  terraform "${ARGS[*]}" init -upgrade -reconfigure
fi

if [ "$1" == "clean" ]; then
  echo "$1: "
  terraform "${ARGS[*]}" destroy -var-file fixtures.tfvars
  rm -rf "{$DIR}"/.terraform
else
  terraform "${ARGS[*]}" validate -compact-warnings
  terraform "${ARGS[*]}" fmt -check -recursive
  terraform "${ARGS[*]}" plan -compact-warnings -var-file fixtures.tfvars -out "$BASE_REF".tfplan
  terraform "${ARGS[*]}" apply -compact-warnings "$BASE_REF".tfplan
  terraform "${ARGS[*]}" show
fi
