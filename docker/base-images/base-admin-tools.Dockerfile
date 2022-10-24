FROM alpine:3.16 AS base-admin-tools

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
    && pip install cqlsh

# set up nsswitch.conf for Go's "netgo" implementation
# https://github.com/gliderlabs/docker-alpine/issues/367#issuecomment-424546457
RUN test ! -e /etc/nsswitch.conf && echo 'hosts: files dns' > /etc/nsswitch.conf

SHELL ["/bin/bash", "-c"]
