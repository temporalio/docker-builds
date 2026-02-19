#!/usr/bin/env bash

set -euo pipefail

modules=(src temporal cli tctl)
has_failures=0

for module in "${modules[@]}"; do
  modfile="${module}/go.mod"
  sumfile="${module}/go.sum"

  if [[ ! -f "${modfile}" ]]; then
    continue
  fi

  echo "Auditing module: ${module}"

  if ! module_list="$(
    cd "${module}" &&
      GOSUMDB="${GOSUMDB:-off}" GONOSUMDB="${GONOSUMDB:-*}" go list -m all
  )"; then
    echo "ERROR: failed to resolve module graph for ${module}." >&2
    has_failures=1
  elif grep -Eq '^github.com/aws/aws-sdk-go([[:space:]]|$)' <<<"${module_list}"; then
    echo "ERROR: ${module} module graph still contains github.com/aws/aws-sdk-go (v1)." >&2
    has_failures=1
  fi

  if rg -n --no-heading 'github\.com/aws/aws-sdk-go(\s|$)' "${modfile}" "${sumfile}" 2>/dev/null; then
    echo "ERROR: ${module} go.mod/go.sum still references github.com/aws/aws-sdk-go (v1)." >&2
    has_failures=1
  fi
done

if rg -n --no-heading --glob '*.go' 'github\.com/aws/aws-sdk-go([[:space:]/"]|$)' temporal cli tctl src 2>/dev/null; then
  echo "ERROR: source files still import github.com/aws/aws-sdk-go (v1)." >&2
  has_failures=1
fi

if [[ "${has_failures}" -ne 0 ]]; then
  exit 1
fi

echo "No github.com/aws/aws-sdk-go (v1) references found."
