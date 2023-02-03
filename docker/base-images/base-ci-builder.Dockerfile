FROM golang:1.19-alpine3.17 AS base-ci-builder

RUN apk add --update --no-cache \
    make \
    git \
    protobuf \
    build-base \
    shellcheck

RUN wget -O- https://raw.githubusercontent.com/fossas/spectrometer/master/install.sh | sh
