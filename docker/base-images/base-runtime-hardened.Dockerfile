ARG BASE_IMAGE=cgr.dev/chainguard/wolfi-base:latest@sha256:c9a27ee8d2d441f941de2f8e4c2c8ddb0b313adb5d14ab934b19f467b9ea8083

FROM ${BASE_IMAGE} AS base-runtime-hardened

RUN apk update && apk upgrade --no-cache && apk add --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl \
    tini \
    netcat-openbsd

SHELL ["/bin/bash", "-c"]
