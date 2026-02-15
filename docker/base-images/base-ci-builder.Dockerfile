FROM golang:1.26.0-alpine3.23 AS base-ci-builder

RUN apk upgrade --no-cache
RUN apk add --no-cache \
    make \
    git \
    protobuf \
    build-base \
    sed \
    shellcheck
