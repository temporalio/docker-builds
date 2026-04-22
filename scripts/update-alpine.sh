#!/bin/bash

# Get latest tag digest
LATEST_DIGEST=$(curl -s "https://hub.docker.com/v2/repositories/library/alpine/tags/latest" | jq -r '.digest')

# Tag order returned will always be `latest`, `X.Y.Z`, `X.Y`, `X`. We want X.Y.Z (e.g., 3.22.1).
ALPINE_VERSION=$(curl -s "https://hub.docker.com/v2/repositories/library/alpine/tags" | jq -r --arg latest_digest "$LATEST_DIGEST" '.results | map(select(.digest == $latest_digest)) | .[1].name')
if ! [[ "$ALPINE_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "unable to retrieve latest alpine version"
  exit 1
fi

ALPINE_MINOR=${ALPINE_VERSION%.*}

# Update both BASE_IMAGE= and FROM statements.
find . -name "*.Dockerfile" -print0 | xargs -0 sed -i '' -E "s/alpine:[0-9.]+/alpine:${ALPINE_VERSION}/g"
find . -name "*.Dockerfile" -print0 | xargs -0 sed -i '' -E "s/alpine[0-9.]+/alpine${ALPINE_MINOR}/g"

echo "Updated Alpine version to ${ALPINE_VERSION} in all Dockerfiles"
