#!/usr/bin/env bash
set -o errexit
curl -k -D- -H 'Host: app.foo.bar' https://$(terraform output -raw alb_hostname)
aws acm list-certificates --max-items 10
