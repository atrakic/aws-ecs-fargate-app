#!/usr/bin/env bash
set -o errexit
curl -k -D- -H 'Host: octocat.example.com' https://$(terraform output -raw alb_hostname)
