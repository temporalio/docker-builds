FROM golang:1.23.2-alpine3.20 AS base-ci-builder

RUN apk add --update --no-cache \
    make \
    git \
    protobuf \
    build-base \
    sed \
    shellcheck
