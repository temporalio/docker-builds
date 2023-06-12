ARG BASE_IMAGE=alpine:3.18

FROM ${BASE_IMAGE} AS builder

RUN apk add --update --no-cache \
    py3-pip \
    python3-dev \
    musl-dev \
    libffi-dev \
    gcc

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip3 install cqlsh yq

FROM ${BASE_IMAGE} AS base-admin-tools

RUN apk add --update --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl \
    jq \
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
