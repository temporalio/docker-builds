#!/bin/bash

set -e

RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

error_msg() {
    echo -e "${RED}Error: $1${NC}" >&2
}
info_msg() {
    echo -e "${CYAN}$1${NC}"
}

SUBMODULE_PATH="$1"
if [[ -z "$SUBMODULE_PATH" ]]; then
    error_msg "Usage: $0 <submodule-path>"
    exit 1
fi
info_msg "Updating $SUBMODULE_PATH/ to latest tag"

REPO_DIR=$(git rev-parse --show-toplevel)
GITHUB_REPO=temporalio/$SUBMODULE_PATH
LATEST_TAG=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | jq -r '.tag_name')
if [[ -z "$LATEST_TAG" ]]; then
    error_msg "Error: Could not fetch latest release tag"
    exit 1
fi
info_msg "Checking out release tag $LATEST_TAG"

# Checkout the submodule to the latest tag
cd "$REPO_DIR"
git submodule update --init "$SUBMODULE_PATH"
cd "$SUBMODULE_PATH"
git fetch --tags
if [[ "$(git rev-parse HEAD)" == "$(git rev-parse "$LATEST_TAG")" ]]; then
    info_msg "Already on latest release tag; exiting"
    exit 0
fi
git checkout "$LATEST_TAG"

# Commit the submodule update
cd "$REPO_DIR"
git add "$SUBMODULE_PATH/"
git commit -m "Updated $SUBMODULE_PATH to $LATEST_TAG" --allow-empty
info_msg "Added commit"
