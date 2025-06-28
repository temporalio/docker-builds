#!/bin/bash

# Tag order returned will always be `latest`, `X.Y.Z`, `X.Y`, `X`. We want X.Y (e.g., 3.22).
ALPINE_VERSION=$(curl -s "https://hub.docker.com/v2/repositories/library/alpine/tags/?page_size=5" | jq -r '.results[2].name')

# Update both BASE_IMAGE= and FROM statements.
find . -name "*.Dockerfile" -print0 | xargs -0 sed -i '' -E "s/alpine:[0-9.]+/alpine:${ALPINE_VERSION}/g; s/alpine[0-9.]+/alpine${ALPINE_VERSION}/g"

echo "Updated Alpine version to ${ALPINE_VERSION} in all Dockerfiles"
