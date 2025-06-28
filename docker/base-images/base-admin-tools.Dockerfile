ARG BASE_IMAGE=registry.access.redhat.com/ubi9/ubi-minimal

FROM ${BASE_IMAGE} AS builder

# These are necessary to install cqlsh
RUN microdnf install -y \
    python3-devel \
    gcc \
    shadow-utils \
    && microdnf clean all

ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin

RUN python3 -m ensurepip && \
    python3 -m pip install --upgrade pip && \
    pip install pipx && \
    pipx install cqlsh

FROM ${BASE_IMAGE} AS base-admin-tools

RUN microdnf install -y \
    python3 \
    ca-certificates \
    tzdata \
    bash \
    jq \
    tar \
    gzip \
    mysql \
    postgresql \
    expat \
    shadow-utils \
    && microdnf clean all

RUN curl -L https://github.com/mikefarah/yq/releases/download/v4.44.1/yq_linux_amd64 -o /usr/bin/yq && \
    chmod +x /usr/bin/yq && \
    curl -Lo /usr/bin/tini https://github.com/krallin/tini/releases/download/v0.19.0/tini && \
    chmod +x /usr/bin/tini

ARG TEMPORAL_VERSION=1.27.2

RUN mkdir -p /usr/local/temporal/bin && \
    curl -fsSL https://github.com/temporalio/temporal/releases/download/v${TEMPORAL_VERSION}/temporal_${TEMPORAL_VERSION}_linux_amd64.tar.gz \
    | tar -xz -C /usr/local/temporal/bin --strip-components=0 && \
    cp /usr/local/temporal/bin/temporal-sql-tool /usr/local/bin/temporal-sql-tool && \
    chmod +x /usr/local/bin/temporal-sql-tool

ENV TEMPORAL_CLI_VERSION=0.13.0

RUN curl -fsSL \
    https://github.com/temporalio/cli/releases/download/v${TEMPORAL_CLI_VERSION}/temporal_cli_${TEMPORAL_CLI_VERSION}_linux_amd64.tar.gz \
    -o /tmp/temporal-cli.tar.gz && \
    tar -xzf /tmp/temporal-cli.tar.gz -C /usr/local/bin temporal && \
    chmod +x /usr/local/bin/temporal && \
    rm /tmp/temporal-cli.tar.gz

COPY --from=builder /opt/pipx /opt/pipx
RUN ln -s /opt/pipx/venvs/cqlsh/bin/cqlsh /usr/local/bin/cqlsh

# Validate cqlsh installation
RUN cqlsh --version

SHELL ["/bin/bash", "-c"]
