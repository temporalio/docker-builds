#!/bin/bash

# Tag order returned will always be `latest`, `X.Y.Z`, `X.Y`, `X`. We want X.Y.Z (e.g., 1.15.11).
BASE_SERVER_VERSION=$(curl -s "https://hub.docker.com/v2/repositories/temporalio/base-server/tags/?page_size=5" | jq -r '.results[1].name')
BASE_TOOLS_VERSION=$(curl -s "https://hub.docker.com/v2/repositories/temporalio/base-admin-tools/tags/?page_size=5" | jq -r '.results[1].name')

# Update Dockerfile references throughout.
find . -name "*.Dockerfile" -print0 | xargs -0 sed -i '' -E "s/temporalio\/base-server:[0-9.]+/temporalio\/base-server:${BASE_SERVER_VERSION}/g; s/temporalio\/base-admin-tools:[0-9.]+/temporalio\/base-admin-tools:${BASE_TOOLS_VERSION}/g"

echo "Updated server base image version to ${BASE_SERVER_VERSION} and admin tools base image version to ${BASE_TOOLS_VERSION}."
