#!/usr/bin/env bash

set -euo pipefail

IMAGE_REPO="${IMAGE_REPO:-temporaliotest}"
IMAGE_TAG="${IMAGE_TAG:-${IMAGE_SHA_TAG:-sha-$(git rev-parse --short HEAD)}}"
OUTPUT_DIR="${OUTPUT_DIR:-scan-results/grype}"
GRYPE_IMAGE="${GRYPE_IMAGE:-anchore/grype@sha256:0844db82d96f22b8010f361474d711b9eaf0f6438f853e75bfdb074094d41a20}"
GRYPE_DB_AUTO_UPDATE="${GRYPE_DB_AUTO_UPDATE:-true}"
GRYPE_CHECK_FOR_APP_UPDATE="${GRYPE_CHECK_FOR_APP_UPDATE:-false}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required for Grype scanning" >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required for Grype scan result parsing" >&2
  exit 2
fi

mkdir -p "${OUTPUT_DIR}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT
grype_cache_dir="${tmp_dir}/grype-cache"
mkdir -p "${grype_cache_dir}"

images=(server admin-tools auto-setup)
total_findings=0

for image in "${images[@]}"; do
  image_ref="${IMAGE_REPO}/${image}:${IMAGE_TAG}"
  archive_path="${tmp_dir}/${image}.tar"
  json_output="${OUTPUT_DIR}/${image}.json"
  sarif_output="${OUTPUT_DIR}/${image}.sarif"

  echo "Grype scan: ${image_ref}"
  docker image inspect "${image_ref}" >/dev/null
  docker save "${image_ref}" -o "${archive_path}"

  if command -v grype >/dev/null 2>&1; then
    GRYPE_DB_AUTO_UPDATE="${GRYPE_DB_AUTO_UPDATE}" \
      GRYPE_CHECK_FOR_APP_UPDATE="${GRYPE_CHECK_FOR_APP_UPDATE}" \
      GRYPE_DB_CACHE_DIR="${grype_cache_dir}" \
      grype "docker-archive:${archive_path}" -o json > "${json_output}"
    GRYPE_DB_AUTO_UPDATE="${GRYPE_DB_AUTO_UPDATE}" \
      GRYPE_CHECK_FOR_APP_UPDATE="${GRYPE_CHECK_FOR_APP_UPDATE}" \
      GRYPE_DB_CACHE_DIR="${grype_cache_dir}" \
      grype "docker-archive:${archive_path}" -o sarif > "${sarif_output}"
  else
    docker run --rm \
      -e GRYPE_DB_AUTO_UPDATE="${GRYPE_DB_AUTO_UPDATE}" \
      -e GRYPE_CHECK_FOR_APP_UPDATE="${GRYPE_CHECK_FOR_APP_UPDATE}" \
      -v "${grype_cache_dir}:/home/grype/.cache" \
      -v "${tmp_dir}:/work" "${GRYPE_IMAGE}" \
      "docker-archive:/work/${image}.tar" -o json > "${json_output}"
    docker run --rm \
      -e GRYPE_DB_AUTO_UPDATE="${GRYPE_DB_AUTO_UPDATE}" \
      -e GRYPE_CHECK_FOR_APP_UPDATE="${GRYPE_CHECK_FOR_APP_UPDATE}" \
      -v "${grype_cache_dir}:/home/grype/.cache" \
      -v "${tmp_dir}:/work" "${GRYPE_IMAGE}" \
      "docker-archive:/work/${image}.tar" -o sarif > "${sarif_output}"
  fi

  findings="$(jq '[.matches[]] | length' "${json_output}")"
  echo "  findings=${findings}"
  total_findings="$((total_findings + findings))"
done

if [[ "${total_findings}" -gt 0 ]]; then
  echo "Grype found ${total_findings} vulnerabilities across images." >&2
  exit 1
fi

echo "Grype found zero vulnerabilities across all images."
