FROM golang:1.23.4-alpine3.21 AS base-ci-builder

RUN apk add --update --no-cache \
    make \
    git \
    protobuf \
    build-base \
    sed \
    shellcheck
