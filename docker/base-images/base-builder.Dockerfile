FROM golang:1.25-alpine3.22 AS base-builder

RUN apk upgrade --no-cache
RUN apk add --no-cache \
    make \
    git \
    curl
