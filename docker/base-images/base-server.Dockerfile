ARG BASE_IMAGE=alpine:3.22

##### base-server target #####
FROM ${BASE_IMAGE} AS base-server

RUN apk upgrade --no-cache
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl

SHELL ["/bin/bash", "-c"]
