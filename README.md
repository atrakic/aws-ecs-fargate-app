# aws-ecs-fargate-stack

[![Terraform Unit Tests](https://github.com/atrakic/aws-ecs-fargate-stack/actions/workflows/tf-unit-tests.yml/badge.svg)](https://github.com/atrakic/aws-ecs-fargate-stack/actions/workflows/tf-unit-tests.yml)
[![Pylint](https://github.com/atrakic/aws-ecs-fargate-stack/actions/workflows/pylint.yml/badge.svg)](https://github.com/atrakic/aws-ecs-fargate-stack/actions/workflows/pylint.yml)
[![license](https://img.shields.io/github/license/atrakic/aws-ecs-fargate-stack.svg)](https://github.com/atrakic/aws-ecs-fargate-stack/blob/main/LICENSE)

> A Messaging processing application with pub-sub functionality.
> Utilizes various AWS components such as SNS, SQS, DynamoDB, and ECS Fargate.

## Introduction
This messaging processing application with access to AWS services: SNS, SQS, DynamoDB and Fargatee.

## Usage flow
- Users submit requests via a URL, as shown in [sample.json](tests/sample.json).
- The Fargate application stores messages in the persistence layer (DynamoDB) and sends a message to a topic (AWS SNS).
- A separate container, the worker application, receives and processes messages from the queues, and deleting them when finished.

## Requirements
- An AWS account

## Deployment

```
$ export AWS_ACCESS_KEY_ID=
$ export AWS_SECRET_ACCESS_KEY=
$ make terraform
```

## Clean up

```
$ make clean
```
