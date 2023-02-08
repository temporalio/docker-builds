FROM alpine:3.17 AS base-admin-tools

RUN apk add --update --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl \
    jq \
    mysql-client \
    postgresql-client \
    py-pip \
    expat \
    tini \
    && pip install cqlsh

SHELL ["/bin/bash", "-c"]
