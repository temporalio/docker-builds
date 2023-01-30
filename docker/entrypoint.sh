#!/bin/bash

set -eu -o pipefail

: "${BIND_ON_IP:=$(getent hosts $(hostname) | awk '{print $1;}')}"
export BIND_ON_IP

# check TEMPORAL_CLI_ADDRESS is not empty
if [[ -z "${TEMPORAL_CLI_ADDRESS:-}" ]]; then
    echo "TEMPORAL_CLI_ADDRESS is not set, setting it to ${BIND_ON_IP}:7233"

    if [[ "${BIND_ON_IP}" =~ ":" ]]; then
        # ipv6
        export TEMPORAL_CLI_ADDRESS="[${BIND_ON_IP}]:7233"
    else
        # ipv4
        export TEMPORAL_CLI_ADDRESS="${BIND_ON_IP}:7233"
    fi
fi

dockerize -template /etc/temporal/config/config_template.yaml:/etc/temporal/config/docker.yaml

# Automatically setup Temporal Server (databases, Elasticsearch, default namespace) if "autosetup" is passed as an argument.
for arg; do [[ ${arg} == autosetup ]] && /etc/temporal/auto-setup.sh && break ; done

# Setup Temporal Server in development mode if "develop" is passed as an argument.
for arg; do [[ ${arg} == develop ]] && /etc/temporal/setup-develop.sh && break ; done

# Run bash instead of Temporal Server if "bash" is passed as an argument (convenient to debug docker image).
for arg; do [[ ${arg} == bash ]] && bash && exit 0 ; done

exec /etc/temporal/start-temporal.sh
