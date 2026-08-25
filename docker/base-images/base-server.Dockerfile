ARG BASE_IMAGE=alpine:3.23.3

FROM golang:1.25.7-alpine3.23 AS builder

ARG DOCKERIZE_VERSION=v0.10.1
RUN go install github.com/jwilder/dockerize@${DOCKERIZE_VERSION}
RUN cp $(which dockerize) /usr/local/bin/dockerize

##### base-server target #####
# Build-only base layer, never run as a container directly: consumers (server.Dockerfile,
# admin-tools.Dockerfile) FROM this via ARG BASE_*_IMAGE and immediately RUN addgroup/adduser
# (needs root) before their own USER temporal. Adding USER here would break that.
# trivy:ignore:DS-0002
FROM ${BASE_IMAGE} AS base-server

RUN apk upgrade --no-cache
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    bash \
    curl

COPY --from=builder /usr/local/bin/dockerize /usr/local/bin

SHELL ["/bin/bash", "-c"]
