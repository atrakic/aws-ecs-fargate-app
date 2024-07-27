#!/usr/bin/env bash
set -o errexit

BASE_REF="$(git rev-parse --abbrev-ref HEAD)"
DIR=terraform

declare -a ARGS
ARGS=("-chdir=$DIR")

if [ -z "$DEPLOYMENT_ENVIRONMENT" ]; then
  declare -a DEPLOY_ARGS=(-var-file fixtures.tfvars)
else
  declare -a DEPLOY_ARGS=()
fi

export TF_IN_AUTOMATION=true

if [ "$1" == "clean" ]; then
  if [ -d "$DIR"/.terraform ]; then
    echo "$1: "
    terraform "${ARGS[*]}" destroy "${DEPLOY_ARGS[@]}" --auto-approve
    rm -rf "{$DIR}"/.terraform
  fi
else
  # prevent from kill signal
  #trap 'exit 0' SIGINT
  terraform "${ARGS[*]}" init -upgrade -reconfigure
  terraform "${ARGS[*]}" validate -compact-warnings
  terraform "${ARGS[*]}" fmt -check -recursive
  terraform "${ARGS[*]}" plan -compact-warnings "${DEPLOY_ARGS[@]}" -out "$BASE_REF".tfplan
  terraform "${ARGS[*]}" apply -compact-warnings "$BASE_REF".tfplan
  terraform "${ARGS[*]}" show
  terraform "${ARGS[*]}" output
  terraform "${ARGS[*]}" state list
  # enable kill signal
  #trap - SIGINT
fi
