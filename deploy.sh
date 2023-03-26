#!/usr/bin/env bash
set -o errexit

this_branch="$(git rev-parse --abbrev-ref HEAD)"

ARGS=("-chdir=terraform")

terraform "${ARGS[*]}" init

terraform "${ARGS[*]}" validate -compact-warnings

terraform "${ARGS[*]}" plan -compact-warnings -out "$this_branch".tfplan

#terraform "${ARGS[*]}" apply -compact-warnings -auto-approve "$this_branch".tfplan
