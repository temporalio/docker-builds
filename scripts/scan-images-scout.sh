#!/usr/bin/env bash

set -euo pipefail

IMAGE_REPO="${IMAGE_REPO:-temporaliotest}"
IMAGE_TAG="${IMAGE_TAG:-${IMAGE_SHA_TAG:-sha-$(git rev-parse --short HEAD)}}"
OUTPUT_DIR="${OUTPUT_DIR:-scan-results/scout}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required for Docker Scout scanning" >&2
  exit 2
fi

if ! docker scout version >/dev/null 2>&1; then
  echo "docker scout is required. Install Docker Scout CLI/plugin first." >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required for Docker Scout scan result parsing" >&2
  exit 2
fi

mkdir -p "${OUTPUT_DIR}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

images=(server admin-tools auto-setup)
total_findings=0

for image in "${images[@]}"; do
  image_ref="${IMAGE_REPO}/${image}:${IMAGE_TAG}"
  sarif_output="${OUTPUT_DIR}/${image}.sarif"
  log_output="${tmp_dir}/${image}.log"

  echo "Docker Scout scan: ${image_ref}"
  docker image inspect "${image_ref}" >/dev/null

  set +e
  docker scout cves \
    --exit-code \
    --format sarif \
    --output "${sarif_output}" \
    "local://${image_ref}" >"${log_output}" 2>&1
  status=$?
  set -e

  if [[ "${status}" -ne 0 && "${status}" -ne 2 ]]; then
    if grep -q "Log in with your Docker ID" "${log_output}"; then
      echo "docker scout requires authentication; run 'docker login' first." >&2
    fi
    cat "${log_output}" >&2
    exit 2
  fi

  findings="$(jq '[.runs[]?.results[]?] | length' "${sarif_output}")"
  echo "  findings=${findings}"
  total_findings="$((total_findings + findings))"
done

if [[ "${total_findings}" -gt 0 ]]; then
  echo "Docker Scout found ${total_findings} vulnerabilities across images." >&2
  exit 1
fi

echo "Docker Scout found zero vulnerabilities across all images."
