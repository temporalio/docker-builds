ARG BASE_IMAGE=alpine:3.23.4

FROM ${BASE_IMAGE} AS builder

# These are necessary to install cqlsh
RUN apk add --update --no-cache \
    python3-dev \
    musl-dev \
    libev-dev \
    gcc \
    pipx

RUN pipx install --global cqlsh

FROM ${BASE_IMAGE} AS base-admin-tools

RUN apk upgrade --no-cache
RUN apk add --no-cache \
    python3 \
    libev \
    ca-certificates \
    tzdata \
    bash \
    curl \
    jq \
    mysql-client \
    postgresql-client \
    expat \
    tini

# Install yq directly from upstream releases rather than the Alpine apk package.
# The Alpine package lags upstream and ships older Go + x/net versions that
# trigger HIGH/CRITICAL grype findings; the upstream release tracks current Go.
ARG TARGETARCH
ARG YQ_VERSION=v4.53.3
RUN curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TARGETARCH}" -o /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq \
    && /usr/local/bin/yq --version

COPY --from=builder /opt/pipx/venvs/cqlsh /opt/pipx/venvs/cqlsh
RUN ln -s /opt/pipx/venvs/cqlsh/bin/cqlsh /usr/local/bin/cqlsh

# validate cqlsh installation
RUN cqlsh --version

SHELL ["/bin/bash", "-c"]
