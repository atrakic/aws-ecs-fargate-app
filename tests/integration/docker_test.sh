#!/usr/bin/env bash
docker run --rm --name ci -p 8080:8080 -d ghcr.io/atrakic/octocat-app:latest
curl -f localhost:8080
docker stop ci
