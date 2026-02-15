FROM golang:1.26.0-alpine3.23 AS base-builder

RUN apk upgrade --no-cache
RUN apk add --no-cache \
    make \
    git \
    curl
