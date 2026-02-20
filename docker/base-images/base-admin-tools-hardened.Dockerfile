ARG BASE_RUNTIME_IMAGE=base-runtime-hardened

FROM ${BASE_RUNTIME_IMAGE} AS base-admin-tools-hardened

RUN apk update && apk upgrade --no-cache && apk add --no-cache \
    jq \
    yq \
    postgresql-18-client \
    cqlsh

# cqlsh packages Python 3.11. Expose python3 for compatibility.
RUN ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
    cqlsh --version && \
    python3 --version

SHELL ["/bin/bash", "-c"]
