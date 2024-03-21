FROM golang:1.22-alpine3.19 AS base-ci-builder

RUN apk add --update --no-cache \
    make \
    git \
    protobuf \
    build-base \
    sed \
    shellcheck
