FROM alpine:3.17 AS base-admin-tools

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
    tini \
    python3-dev \
    musl-dev \
    libffi-dev \
    gcc

RUN pip3 install cqlsh

SHELL ["/bin/bash", "-c"]
