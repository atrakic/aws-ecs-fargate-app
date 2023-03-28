#!/usr/bin/env bash
DIR=terraform
test -d "$DIR"/.terraform || terraform -chdir="$DIR" init
terraform -chdir="$DIR" plan \
  -compact-warnings \
  -detailed-exitcode \
  -var 'alb_tls_cert_arn=arn:aws:acm::123456789012:certificate/tf-acc-test-6453083910015726063'
