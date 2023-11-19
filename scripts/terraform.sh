#!/usr/bin/env bash
set -o errexit

BASE_REF="$(git rev-parse --abbrev-ref HEAD)"

DIR=terraform

ARGS=("-chdir=$DIR")

export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}

aws --endpoint-url=http://localhost:4566 sts get-caller-identity | cat -

[ ! -f "{$DIR}"/.terraform/terraform.tfstate ] || terraform "${ARGS[*]}" init -upgrade -reconfigure
if [ "$1" == "clean" ]; then
  echo "$1: "
  terraform "${ARGS[*]}" destroy -var-file fixtures.tfvars
  rm -rf "{$DIR}"/.terraform
else
  terraform "${ARGS[*]}" validate -compact-warnings
  #terraform "${ARGS[*]}" fmt -check -recursive
  terraform "${ARGS[*]}" plan -compact-warnings -var-file fixtures.tfvars -out "$BASE_REF".tfplan
  terraform "${ARGS[*]}" apply -compact-warnings "$BASE_REF".tfplan
  terraform "${ARGS[*]}" show
fi
