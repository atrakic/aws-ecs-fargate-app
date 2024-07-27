# aws-ecs-fargate-stack

[![Terraform Unit Tests](https://github.com/atrakic/aws-ecs-fargate-stack/actions/workflows/tf-unit-tests.yml/badge.svg)](https://github.com/atrakic/aws-ecs-fargate-stack/actions/workflows/tf-unit-tests.yml)
[![Pylint](https://github.com/atrakic/aws-ecs-fargate-stack/actions/workflows/pylint.yml/badge.svg)](https://github.com/atrakic/aws-ecs-fargate-stack/actions/workflows/pylint.yml)
[![license](https://img.shields.io/github/license/atrakic/aws-ecs-fargate-stack.svg)](https://github.com/atrakic/aws-ecs-fargate-stack/blob/main/LICENSE)

> A Messaging processing application with pub-sub functionality.
> Utilizes various AWS components such as SNS, SQS, DynamoDB, and ECS Fargate.

## Introduction
This application showcases the deployment and configuration of a Fargate container to interact with AWS services like SNS, SQS, and DynamoDB.

## Usage flow
- Users submit requests via a URL, as shown in [sample.json](tests/sample.json).
- The Fargate application stores messages in the persistence layer (DynamoDB) and sends a message to a topic (AWS SNS).
- A separate container, the worker application, receives and processes messages from the queues, deleting them when finished.

## Requirements
- An AWS account

## Deployment

```
$ cp -f ./terraform/terraform.tfvars.example ./terraform/terraform.tfvars
$ vim terraform/terraform.tfvars
$ vim terraform/
$ DEPLOYMENT_ENVIRONMENT=prod make terraform
```

## Clean up

```
$ DEPLOYMENT_ENVIRONMENT=prod make clean
```
