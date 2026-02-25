ARG BASE_IMAGE=alpine:3.23.3

FROM ${BASE_IMAGE} AS builder

# These are necessary to install cqlsh
RUN apk add --update --no-cache \
    python3-dev \
    musl-dev \
    libev-dev \
    gcc \
    g++ \
    pipx

# cassandra-driver source builds still import pkg_resources via ez_setup.
# Setuptools v82 removed pkg_resources: https://setuptools.pypa.io/en/latest/history.html#v82-0-0
# On Alpine, cassandra-driver is built from source (no musllinux wheels), so pip's isolated
# build env must be constrained to setuptools<81 or the build fails.
RUN printf 'setuptools<81\n' > /tmp/pip-build-constraints.txt && \
    PIP_CONSTRAINT=/tmp/pip-build-constraints.txt pipx install --global cqlsh && \
    rm -f /tmp/pip-build-constraints.txt

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
    yq \
    mysql-client \
    postgresql-client \
    expat \
    tini

COPY --from=builder /opt/pipx/venvs/cqlsh /opt/pipx/venvs/cqlsh
RUN ln -s /opt/pipx/venvs/cqlsh/bin/cqlsh /usr/local/bin/cqlsh

# validate cqlsh installation
RUN cqlsh --version

SHELL ["/bin/bash", "-c"]
