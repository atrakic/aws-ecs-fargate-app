#!/usr/bin/env bash
set -o errexit

BASE_REF="$(git rev-parse --abbrev-ref HEAD)"

DIR=terraform

ARGS=("-chdir=$DIR")

export TF_IN_AUTOMATION=true
export TF_CLI_ARGS_init="-input=false"

if [ "$1" == "clean" ]; then
  echo "$1: "
  terraform "${ARGS[*]}" destroy -var-file fixtures.tfvars --auto-approve
  rm -rf "{$DIR}"/.terraform
else
  if [ ! -d "$DIR"/.terraform ]; then
    terraform "${ARGS[*]}" init -upgrade -reconfigure
  fi
  terraform "${ARGS[*]}" validate -compact-warnings
  terraform "${ARGS[*]}" fmt -check -recursive
  terraform "${ARGS[*]}" plan -compact-warnings -var-file fixtures.tfvars -out "$BASE_REF".tfplan
  terraform "${ARGS[*]}" apply -compact-warnings "$BASE_REF".tfplan
  terraform "${ARGS[*]}" show
fi
