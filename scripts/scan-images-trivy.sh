#!/usr/bin/env bash

set -euo pipefail

IMAGE_REPO="${IMAGE_REPO:-temporaliotest}"
IMAGE_TAG="${IMAGE_TAG:-${IMAGE_SHA_TAG:-sha-$(git rev-parse --short HEAD)}}"
OUTPUT_DIR="${OUTPUT_DIR:-scan-results/trivy}"
TRIVY_SEVERITIES="${TRIVY_SEVERITIES:-UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL}"
TRIVY_SKIP_DB_UPDATE="${TRIVY_SKIP_DB_UPDATE:-true}"

if ! command -v trivy >/dev/null 2>&1; then
  echo "trivy is required for Trivy scanning" >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required for Trivy scan result parsing" >&2
  exit 2
fi

mkdir -p "${OUTPUT_DIR}"

images=(server admin-tools auto-setup)
total_findings=0

for image in "${images[@]}"; do
  image_ref="${IMAGE_REPO}/${image}:${IMAGE_TAG}"
  json_output="${OUTPUT_DIR}/${image}.json"
  sarif_output="${OUTPUT_DIR}/${image}.sarif"

  echo "Trivy scan: ${image_ref}"
  TRIVY_SKIP_DB_UPDATE="${TRIVY_SKIP_DB_UPDATE}" \
    trivy image \
    --scanners vuln \
    --severity "${TRIVY_SEVERITIES}" \
    --no-progress \
    --format json \
    --output "${json_output}" \
    "${image_ref}"

  TRIVY_SKIP_DB_UPDATE="${TRIVY_SKIP_DB_UPDATE}" \
    trivy image \
    --scanners vuln \
    --severity "${TRIVY_SEVERITIES}" \
    --no-progress \
    --format sarif \
    --output "${sarif_output}" \
    "${image_ref}"

  findings="$(jq '[.Results[]?.Vulnerabilities[]?] | length' "${json_output}")"
  echo "  findings=${findings}"
  total_findings="$((total_findings + findings))"
done

if [[ "${total_findings}" -gt 0 ]]; then
  echo "Trivy found ${total_findings} vulnerabilities across images." >&2
  exit 1
fi

echo "Trivy found zero vulnerabilities across all images."
