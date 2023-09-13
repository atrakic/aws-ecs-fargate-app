#!/usr/bin/env bash
set -o errexit

this_branch="$(git rev-parse --abbrev-ref HEAD)"

ARGS=("-chdir=infra")

terraform "${ARGS[*]}" init

terraform "${ARGS[*]}" validate -compact-warnings

terraform "${ARGS[*]}" plan -compact-warnings -out "$this_branch".tfplan

terraform "${ARGS[*]}" apply -compact-warnings "$this_branch".tfplan

terraform "${ARGS[*]}" show
