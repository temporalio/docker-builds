FROM golang:1.21-alpine3.18 AS base-ci-builder

RUN apk add --update --no-cache \
    make \
    git \
    protobuf \
    build-base \
    shellcheck

RUN wget -O- https://raw.githubusercontent.com/fossas/spectrometer/master/install.sh | sh
