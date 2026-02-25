FROM golang:1.25.7-alpine3.23 AS base-ci-builder

RUN apk upgrade --no-cache
RUN apk add --no-cache \
    make \
    git \
    protobuf \
    build-base \
    sed \
    shellcheck
