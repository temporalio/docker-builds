ARG BASE_IMAGE=alpine:3.20

FROM ${BASE_IMAGE} AS builder

# Need to pin Python3 until the following issue is resolved, otherwise cqlsh wont work
# https://issues.apache.org/jira/browse/CASSANDRA-19206
RUN apk add --update --no-cache \
    python3~3.11 \
    py3-pip \
    python3-dev \
    musl-dev \
    libffi-dev \
    gcc

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip3 install cqlsh

FROM ${BASE_IMAGE} AS base-admin-tools

RUN apk add --update --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl \
    jq \
    yq \
    mysql-client \
    postgresql-client \
    py3-pip \
    expat \
    tini

COPY --from=builder /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

# validate installation
RUN cqlsh --version

SHELL ["/bin/bash", "-c"]
